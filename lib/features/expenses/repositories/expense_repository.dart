import 'package:mineai/config/firebase/notification_service.dart';
import 'package:mineai/core/database/app_database.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

abstract class ExpenseRepository {
  Future<void> addTransaction(TransactionModel item, bool isSubscribed);
  Future<void> deleteTransaction(int id, String userId);
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<List<TransactionModel>> getTransactionsFiltered(
    String userId, {
    String? monthYear,
    String? year,
    String? type,
  });
  Future<List<CategoryModel>> getCategories(String userId, String type);
  Future<void> addCustomCategory(CategoryModel category, bool isSubscribed);
  Future<void> setOrUpdateBudget(BudgetModel budget, bool isSubscribed);
  Future<List<BudgetProgress>> getBudgetProgressList(
    String userId,
    String monthYear,
  );
}

class BudgetProgress {
  final CategoryModel category;
  final BudgetModel budget;
  final double spent;
  final double percentage;

  BudgetProgress({
    required this.category,
    required this.budget,
    required this.spent,
    required this.percentage,
  });
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDatabaseService _dbService;

  ExpenseRepositoryImpl({ExpenseDatabaseService? dbService})
    : _dbService = dbService ?? ExpenseDatabaseService.instance;

  @override
  Future<void> addTransaction(TransactionModel item, bool isSubscribed) async {
    // 1. Insert transaction into local SQLite
    await _dbService.insertTransaction(item);

    // 2. If it is an expense, check limits against the category budget
    if (item.type == 'expense') {
      final monthYear =
          "${item.time.year}-${item.time.month.toString().padLeft(2, '0')}";

      final budget = await _dbService.getBudget(
        item.userId,
        item.categoryId,
        monthYear,
      );

      if (budget != null && budget.allocatedAmount > 0) {
        final totalSpent = await _dbService.getCategorySpentAmount(
          item.userId,
          item.categoryId,
          monthYear,
        );
        final percentage = (totalSpent / budget.allocatedAmount) * 100;

        if (percentage >= 80) {
          final categories = await _dbService.getCategories(
            item.userId,
            'expense',
          );
          final categoryName = categories
              .firstWhere(
                (c) => c.id == item.categoryId,
                orElse: () =>
                    CategoryModel(id: '', name: 'Expense', type: 'expense'),
              )
              .name;

          await NotificationService.instance.showBudgetWarning(
            categoryName: categoryName,
            percentage: percentage,
            spent: totalSpent,
            limit: budget.allocatedAmount,
          );
        }
      }
    }
  }

  @override
  Future<void> deleteTransaction(int id, String userId) async {
    await _dbService.deleteTransaction(id, userId);
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId) {
    return _dbService.getTransactions(userId);
  }

  @override
  Future<List<TransactionModel>> getTransactionsFiltered(
    String userId, {
    String? monthYear,
    String? year,
    String? type,
  }) {
    return _dbService.getTransactionsFiltered(
      userId,
      monthYear: monthYear,
      year: year,
      type: type,
    );
  }

  @override
  Future<List<CategoryModel>> getCategories(String userId, String type) {
    return _dbService.getCategories(userId, type);
  }

  @override
  Future<void> addCustomCategory(
    CategoryModel category,
    bool isSubscribed,
  ) async {
    if (!isSubscribed) {
      throw Exception(
        'Creating custom categories requires a Pro/Ultra Subscription.',
      );
    }
    await _dbService.insertCustomCategory(category);
  }

  @override
  Future<void> setOrUpdateBudget(BudgetModel budget, bool isSubscribed) async {
    final existing = await _dbService.getBudget(
      budget.userId,
      budget.categoryId,
      budget.monthYear,
    );

    if (existing != null) {
      // Editing existing budget
      if (existing.editCount >= 2 && !isSubscribed) {
        throw Exception(
          'Free limit reached! You can only edit budgets twice per month. Upgrade to Pro for unlimited edits.',
        );
      }

      final updated = existing.copyWith(
        allocatedAmount: budget.allocatedAmount,
        editCount: existing.editCount + 1,
        updatedAt: DateTime.now(),
      );
      await _dbService.saveOrUpdateBudget(updated);
    } else {
      // Initial creation
      await _dbService.saveOrUpdateBudget(budget);
    }
  }

  @override
  Future<List<BudgetProgress>> getBudgetProgressList(
    String userId,
    String monthYear,
  ) async {
    final budgets = await _dbService.getAllBudgets(userId, monthYear);
    final categories = await _dbService.getCategories(userId, 'expense');
    List<BudgetProgress> list = [];

    for (var b in budgets) {
      final cat = categories.firstWhere(
        (c) => c.id == b.categoryId,
        orElse: () =>
            CategoryModel(id: b.categoryId, name: 'General', type: 'expense'),
      );
      final spent = await _dbService.getCategorySpentAmount(
        userId,
        b.categoryId,
        monthYear,
      );
      final pct = b.allocatedAmount > 0
          ? (spent / b.allocatedAmount) * 100
          : 0.0;

      list.add(
        BudgetProgress(category: cat, budget: b, spent: spent, percentage: pct),
      );
    }
    return list;
  }
}
