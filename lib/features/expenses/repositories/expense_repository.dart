import 'package:mineai/config/firebase/notification_service.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/instance/locator.dart';
import 'package:mineai/features/subscription/models/subscription_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

abstract class ExpenseRepository {
  Future<void> addTransaction(TransactionModel item, bool syncToCloud);
  Future<List<TransactionModel>> getTransactions(String userId);

  // Added methods
  Future<List<TransactionModel>> getTransactionsFiltered(
    String userId, {
    String? monthYear,
    String? year,
    String? type,
  });
  Future<int> deleteTransaction(int id, String userId);

  Future<List<CategoryModel>> getCategories(String userId, String type);
  Future<void> addCustomCategory(CategoryModel category, bool isSubscribed);
  Future<void> setOrUpdateBudget(BudgetModel budget, SubscriptionPlan plan);
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
  Future<void> addTransaction(TransactionModel item, bool syncToCloud) async {
    await _dbService.insertTransaction(item);

    if (syncToCloud) {
      try {
        await Supabase.instance.client.from('transactions').upsert({
          'user_id': item.userId,
          'title': item.title,
          'amount': item.amount,
          'type': item.type,
          'category_id': item.categoryId,
          'time': item.time.toIso8601String(),
          'update_time': DateTime.now().toIso8601String(),
          'note': item.note,
        });
      } catch (_) {}
    }

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
        final previousSpent = (totalSpent - item.amount).clamp(
          0.0,
          double.infinity,
        );
        final previousPercentage =
            (previousSpent / budget.allocatedAmount) * 100;
        final percentage = (totalSpent / budget.allocatedAmount) * 100;
        final crossedThresholds = [50, 90, 100].where(
          (threshold) =>
              previousPercentage < threshold && percentage >= threshold,
        );

        if (crossedThresholds.isNotEmpty) {
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

          // Only dispatch device push notification if user enabled notifications for this device
          final notifPref = await getIt<CustomSecureStorage>().readSecureData('push_notifications_enabled');
          final bool notificationsAllowed = notifPref != 'false';

          if (notificationsAllowed) {
            for (final threshold in crossedThresholds) {
              await NotificationService.instance.showBudgetWarning(
                categoryName: categoryName,
                threshold: threshold,
                spent: totalSpent,
                limit: budget.allocatedAmount,
              );
            }
          }
        }
      }
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId) {
    return _dbService.getTransactions(userId);
  }

  // Implementation for getTransactionsFiltered
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

  // Implementation for deleteTransaction
  @override
  Future<int> deleteTransaction(int id, String userId) async {
    final deletedCount = await _dbService.deleteTransaction(id, userId);

    // Clean up cloud record if active
    try {
      await Supabase.instance.client.from('transactions').delete().match({
        'id': id,
        'user_id': userId,
      });
    } catch (_) {}

    return deletedCount;
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
        'Creating custom categories requires a Pro/Premium Subscription.',
      );
    }
    await _dbService.insertCustomCategory(category);
  }

  @override
  Future<void> setOrUpdateBudget(
    BudgetModel budget,
    SubscriptionPlan plan,
  ) async {
    final existing = await _dbService.getBudget(
      budget.userId,
      budget.categoryId,
      budget.monthYear,
    );

    if (existing != null) {
      if (existing.editCount >= plan.monthlyBudgetEdits) {
        throw Exception(
          'Edit limit reached! Your ${plan.tier.name.toUpperCase()} plan allows ${plan.monthlyBudgetEdits} edits per month.',
        );
      }

      final updated = existing.copyWith(
        allocatedAmount: budget.allocatedAmount,
        editCount: existing.editCount + 1,
        updatedAt: DateTime.now(),
      );
      await _dbService.saveOrUpdateBudget(updated);
    } else {
      final allBudgets = await _dbService.getAllBudgets(
        budget.userId,
        budget.monthYear,
      );
      if (allBudgets.length >= plan.maxBudgets) {
        throw Exception(
          'Maximum budget limit reached (${plan.maxBudgets} budgets) for your plan.',
        );
      }
      await _dbService.saveOrUpdateBudget(budget);
    }

    if (plan.cloudSyncEnabled) {
      try {
        await Supabase.instance.client.from('budgets').upsert({
          'id': '${budget.userId}_${budget.categoryId}_${budget.monthYear}',
          'user_id': budget.userId,
          'category_id': budget.categoryId,
          'allocated_amount': budget.allocatedAmount,
          'month_year': budget.monthYear,
          'edit_count': (existing?.editCount ?? 0) + (existing != null ? 1 : 0),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
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
