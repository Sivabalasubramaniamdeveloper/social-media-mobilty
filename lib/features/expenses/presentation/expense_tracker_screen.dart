import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/firebase/notification_service.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_text_styles.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/widgets.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:mineai/instance/locator.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _quickType = 'expense';
  String _selectedCategoryId = '';
  String _selectedPeriod = 'This Week';
  bool _isLoading = true;

  List<TransactionModel> _allTransactions = [];
  List<CategoryModel> _expenseCategories = [];
  List<CategoryModel> _incomeCategories = [];
  List<BudgetProgress> _budgetProgressList = [];
  double? _monthlySavingsGoal;

  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;

  String get _currentMonthYear => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadAllData();
    NotificationService.instance.requestIOSPermissions();
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final userId = await getCurrentUserId();
    final monthYear = _currentMonthYear;

    try {
      final expCats = await ExpenseDatabaseService.instance.getCategories(
        userId,
        'expense',
      );
      final incCats = await ExpenseDatabaseService.instance.getCategories(
        userId,
        'income',
      );

      final items = await ExpenseDatabaseService.instance.getTransactions(userId);
      double expTotal = 0.0;
      double incTotal = 0.0;
      for (final item in items) {
        if (item.type == 'income') {
          incTotal += item.amount;
        } else {
          expTotal += item.amount;
        }
      }

      final repo = ExpenseRepositoryImpl();
      final progress = await repo.getBudgetProgressList(userId, monthYear);
      final goal = await ExpenseDatabaseService.instance.getSavingsGoal(
        userId,
        monthYear,
      );

      if (mounted) {
        setState(() {
          _expenseCategories = expCats;
          _incomeCategories = incCats;
          if (_selectedCategoryId.isEmpty && expCats.isNotEmpty) {
            _selectedCategoryId = expCats.first.id;
          }
          _allTransactions = items;
          _totalExpenses = expTotal;
          _totalIncome = incTotal;
          _budgetProgressList = progress;
          _monthlySavingsGoal = goal;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _trackQuickTransaction() async {
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.fieldRequired),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final userId = await getCurrentUserId();
    final catList = _quickType == 'expense'
        ? _expenseCategories
        : _incomeCategories;
    final selectedCat = catList.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => catList.first,
    );

    final tx = TransactionModel(
      userId: userId,
      title: selectedCat.name,
      amount: amount,
      type: _quickType,
      categoryId: selectedCat.id,
      time: DateTime.now(),
      updateTime: DateTime.now(),
    );

    await ExpenseRepositoryImpl().addTransaction(tx, false);
    _amountController.clear();
    await _loadAllData();
  }

  Future<void> _showSavingsGoalDialog() async {
    final userId = await getCurrentUserId();
    if (!mounted) return;
    await SavingsGoalDialog.show(
      context,
      userId: userId,
      monthYear: _currentMonthYear,
      currentGoal: _monthlySavingsGoal,
      onSaved: _loadAllData,
    );
  }

  Future<void> _showSetBudgetDialog() async {
    final userId = await getCurrentUserId();
    if (!mounted) return;
    await SetBudgetDialog.show(
      context,
      userId: userId,
      monthYear: _currentMonthYear,
      onSaved: _loadAllData,
    );
  }

  Future<void> _openAddScreen() async {
    final res = await context.push(RouteNames.addExpense);
    if (res == true) _loadAllData();
  }

  Future<void> _openBudgetScreen() async {
    final res = await context.push(RouteNames.incomeBudget);
    if (res == true) _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppSizes.tabletBreakpoint;
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final totalBalance = _totalIncome - _totalExpenses;
    final activeCategories = _quickType == 'expense'
        ? _expenseCategories
        : _incomeCategories;

    return Scaffold(
      floatingActionButton: _buildFab(),
      body: GradientBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              )
            : SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? size.width * 0.15 : AppSizes.pagePadding,
                    AppSizes.lg,
                    isTablet ? size.width * 0.15 : AppSizes.pagePadding,
                    110,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: AppSizes.xl),
                      BalanceOverviewCard(
                        totalBalance: totalBalance,
                        totalIncome: _totalIncome,
                        totalExpenses: _totalExpenses,
                        currencyFormat: currencyFormat,
                        onWalletTap: _openBudgetScreen,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      SavingsGoalCard(
                        monthlySavingsGoal: _monthlySavingsGoal,
                        totalBalance: totalBalance,
                        currencyFormat: currencyFormat,
                        onTap: _showSavingsGoalDialog,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      BudgetProgressCard.fromProgressList(
                        title: AppStrings.budgetTracker,
                        actionText: AppStrings.setBudget,
                        onActionTap: _showSetBudgetDialog,
                        list: _budgetProgressList,
                        currencyFormat: currencyFormat,
                        maxDisplayCount: 3,
                        onViewAllTap: _openBudgetScreen,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      SpendingGraphCard(
                        transactions: _allTransactions,
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: (val) =>
                            setState(() => _selectedPeriod = val),
                      ),
                      const SizedBox(height: AppSizes.xxl),
                      QuickTrackSection(
                        amountController: _amountController,
                        quickType: _quickType,
                        selectedCategoryId: _selectedCategoryId,
                        categories: activeCategories,
                        onTypeChanged: (type) {
                          setState(() {
                            _quickType = type;
                            final list = type == 'expense'
                                ? _expenseCategories
                                : _incomeCategories;
                            _selectedCategoryId =
                                list.isNotEmpty ? list.first.id : '';
                          });
                        },
                        onCategoryChanged: (val) =>
                            setState(() => _selectedCategoryId = val),
                        onTrack: _trackQuickTransaction,
                      ),
                      const SizedBox(height: AppSizes.xxl),
                      _buildRecentTransactionsSection(context, currencyFormat),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryPurpleLight, AppColors.primaryPurpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurpleLight.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        onPressed: _openAddScreen,
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.whiteColor,
          size: AppSizes.iconXxl,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.expenseTracker,
              style: TextStyle(
                fontSize: AppSizes.fontHeaderLg,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              AppStrings.manageYourSpending,
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.accentLavender,
                size: AppSizes.iconLg,
              ),
              tooltip: 'Notification',
              onPressed: () async {
                await NotificationService.instance.showNotification(
                  id: 1,
                  title: 'MindAI Expense Digest',
                  body: 'Daily financial activity updated successfully.',
                  payload: 'custom_data_payload',
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.accentLavender,
                size: AppSizes.iconLg,
              ),
              tooltip: AppStrings.setBudget,
              onPressed: _openBudgetScreen,
            ),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.accentLavender,
                size: AppSizes.iconLg,
              ),
              tooltip: AppStrings.expenseSettings,
              onPressed: () async {
                final res = await context.push(RouteNames.expenseSettings);
                if (res == true) _loadAllData();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(
    BuildContext context,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: AppStrings.recentTransactions,
          actionLabel: AppStrings.seeAll,
          onAction: () async {
            final res = await context.push(RouteNames.allTransactions);
            if (res == true) _loadAllData();
          },
        ),
        const SizedBox(height: AppSizes.sm + 2),
        if (_allTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
              border: Border.all(
                color: AppColors.whiteColor.withValues(alpha: 0.05),
              ),
            ),
            child: Center(
              child: Text(
                AppStrings.noTransactionsLogged,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: AppSizes.fontBodySm,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allTransactions.length > 5 ? 5 : _allTransactions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.sm + 2),
            itemBuilder: (context, index) {
              return TransactionTile(
                transaction: _allTransactions[index],
                currencyFormat: currencyFormat,
                onTap: _openAddScreen,
              );
            },
          ),
      ],
    );
  }
}
