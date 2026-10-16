import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../repositories/expense_repository.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();
  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<TransactionModel> transactions;
  final List<CategoryModel> expenseCategories;
  final List<CategoryModel> incomeCategories;
  final List<BudgetProgress> budgetProgress;
  final double totalIncome;
  final double totalExpenses;

  const FinanceLoaded({
    required this.transactions,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.budgetProgress,
    required this.totalIncome,
    required this.totalExpenses,
  });

  double get balance => totalIncome - totalExpenses;

  @override
  List<Object?> get props => [
    transactions,
    expenseCategories,
    incomeCategories,
    budgetProgress,
    totalIncome,
    totalExpenses,
  ];
}

class FinanceActionError extends FinanceState {
  final String message;
  const FinanceActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpgradeRequiredState extends FinanceState {
  final String reason;
  const UpgradeRequiredState(this.reason);

  @override
  List<Object?> get props => [reason];
}
