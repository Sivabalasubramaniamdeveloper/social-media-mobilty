import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  final ExpenseRepository _repository;

  FinanceCubit({required ExpenseRepository repository})
    : _repository = repository,
      super(FinanceInitial());

  Future<void> loadDashboard({
    required String userId,
    required String monthYear,
  }) async {
    emit(FinanceLoading());
    try {
      final transactions = await _repository.getTransactions(userId);
      final expCats = await _repository.getCategories(userId, 'expense');
      final incCats = await _repository.getCategories(userId, 'income');
      final budgetProgress = await _repository.getBudgetProgressList(
        userId,
        monthYear,
      );

      double totalInc = 0;
      double totalExp = 0;

      for (var t in transactions) {
        if (t.type == 'income') {
          totalInc += t.amount;
        } else {
          totalExp += t.amount;
        }
      }

      emit(
        FinanceLoaded(
          transactions: transactions,
          expenseCategories: expCats,
          incomeCategories: incCats,
          budgetProgress: budgetProgress,
          totalIncome: totalInc,
          totalExpenses: totalExp,
        ),
      );
    } catch (e) {
      emit(FinanceActionError(e.toString()));
    }
  }

  Future<void> addTransaction({
    required TransactionModel transaction,
    required bool isSubscribed,
    required String monthYear,
  }) async {
    try {
      await _repository.addTransaction(transaction, isSubscribed);
      await loadDashboard(userId: transaction.userId, monthYear: monthYear);
    } catch (e) {
      emit(FinanceActionError(e.toString()));
    }
  }

  Future<void> addCustomCategory({
    required CategoryModel category,
    required bool isSubscribed,
    required String monthYear,
  }) async {
    try {
      await _repository.addCustomCategory(category, isSubscribed);
      await loadDashboard(userId: category.userId ?? '', monthYear: monthYear);
    } catch (e) {
      if (e.toString().contains('Subscription')) {
        emit(UpgradeRequiredState(e.toString().replaceAll('Exception: ', '')));
      } else {
        emit(FinanceActionError(e.toString()));
      }
    }
  }

  Future<void> setBudget({
    required BudgetModel budget,
    required bool isSubscribed,
  }) async {
    try {
      // await _repository.setOrUpdateBudget(budget, isSubscribed);
      await loadDashboard(userId: budget.userId, monthYear: budget.monthYear);
    } catch (e) {
      if (e.toString().contains('Upgrade to Pro')) {
        emit(UpgradeRequiredState(e.toString().replaceAll('Exception: ', '')));
      } else {
        emit(FinanceActionError(e.toString()));
      }
    }
  }
}
