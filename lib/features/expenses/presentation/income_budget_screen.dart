import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/features/expenses/models/budget_model.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/widgets.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:mineai/instance/locator.dart';

class IncomeBudgetScreen extends StatefulWidget {
  const IncomeBudgetScreen({super.key});

  @override
  State<IncomeBudgetScreen> createState() => _IncomeBudgetScreenState();
}

class _IncomeBudgetScreenState extends State<IncomeBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedIncomeSource = 'Monthly Salary';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  double _totalIncome = 0.0;
  List<BudgetModel> _budgets = [];
  Map<String, double> _spentByCategory = {};
  List<TransactionModel> _recentIncome = [];

  final List<String> _incomeSources = [
    'Monthly Salary',
    'Freelance',
    'Investments',
    'Bonus',
    'Other Income',
  ];

  String get _currentMonthYear => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String> getCurrentUserId() async {
    final secureStorage = getIt<CustomSecureStorage>();
    final savedId = await secureStorage.readSecureData('userId');
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }
    return 'guest_user';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = await getCurrentUserId();
    final monthYear = _currentMonthYear;

    final allTx = await ExpenseDatabaseService.instance.getTransactions(userId);
    final userBudgets = await ExpenseDatabaseService.instance.getAllBudgets(
      userId,
      monthYear,
    );

    double incomeSum = 0.0;
    List<TransactionModel> incomeList = [];
    for (var tx in allTx) {
      if (tx.type == 'income') {
        incomeSum += tx.amount;
        incomeList.add(tx);
      }
    }

    Map<String, double> spentMap = {};
    for (var b in userBudgets) {
      final spent = await ExpenseDatabaseService.instance
          .getCategorySpentAmount(userId, b.categoryId, monthYear);
      spentMap[b.categoryId] = spent;
    }

    if (mounted) {
      setState(() {
        _totalIncome = incomeSum;
        _budgets = userBudgets;
        _spentByCategory = spentMap;
        _recentIncome = incomeList;
        _isLoading = false;
      });
    }
  }

  Future<void> _addIncome() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.enterValidAmount),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final userId = await getCurrentUserId();

    final tx = TransactionModel(
      userId: userId,
      title: _selectedIncomeSource,
      amount: amount,
      type: 'income',
      categoryId: _selectedIncomeSource,
      time: _selectedDate,
      updateTime: DateTime.now(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await ExpenseRepositoryImpl().addTransaction(tx, false);
    _amountController.clear();
    _noteController.clear();
    await _loadData();
  }

  Future<void> _showSetBudgetDialog() async {
    final userId = await getCurrentUserId();
    if (!mounted) return;
    await SetBudgetDialog.show(
      context,
      userId: userId,
      monthYear: _currentMonthYear,
      onSaved: _loadData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    final budgetItems = _budgets.map((b) {
      final spent = _spentByCategory[b.categoryId] ?? 0.0;
      final pct = b.allocatedAmount > 0
          ? ((spent / b.allocatedAmount) * 100)
          : 0.0;
      return BudgetProgressItemModel(
        categoryId: b.categoryId,
        categoryName: b.categoryId,
        spent: spent,
        allocated: b.allocatedAmount,
        percentage: pct,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      title: AppStrings.incomeAndBudget,
                      titleSize: AppSizes.fontHeading,
                      onBack: () => context.pop(true),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primaryPurple,
                          size: AppSizes.iconLg,
                        ),
                        onPressed: _showSetBudgetDialog,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    IncomeOverviewCard(
                      totalIncome: _totalIncome,
                      currencyFormat: currencyFormat,
                    ),
                    const SizedBox(height: AppSizes.xxl),
                    BudgetProgressCard(
                      title: AppStrings.budgetProgress,
                      actionText: DateFormat(
                        'MMMM yyyy',
                      ).format(DateTime.now()),
                      onActionTap: _showSetBudgetDialog,
                      items: budgetItems,
                      currencyFormat: currencyFormat,
                    ),
                    const SizedBox(height: AppSizes.xxl),
                    AppSectionHeader(title: AppStrings.addIncome),
                    const SizedBox(height: AppSizes.md),
                    IncomeEntryCard(
                      amountController: _amountController,
                      noteController: _noteController,
                      selectedSource: _selectedIncomeSource,
                      sourceOptions: _incomeSources,
                      selectedDate: _selectedDate,
                      onSourceChanged: (val) =>
                          setState(() => _selectedIncomeSource = val),
                      onDateChanged: (val) =>
                          setState(() => _selectedDate = val),
                      onSubmit: _addIncome,
                    ),
                    const SizedBox(height: AppSizes.xxl),
                    AppSectionHeader(title: AppStrings.recentGains),
                    const SizedBox(height: AppSizes.md),
                    if (_recentIncome.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.xl,
                          ),
                          child: Text(
                            AppStrings.noIncomeLogged,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: AppSizes.fontCaption,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentIncome.length > 5
                            ? 5
                            : _recentIncome.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSizes.sm + 2),
                        itemBuilder: (context, index) {
                          return TransactionTile(
                            transaction: _recentIncome[index],
                            currencyFormat: currencyFormat,
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
