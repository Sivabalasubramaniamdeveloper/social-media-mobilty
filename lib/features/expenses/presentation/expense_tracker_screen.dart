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
import 'package:mineai/core/utils/user_helper.dart';
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
    NotificationService.instance.requestAndroidPermissions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final userId = await UserHelper.getCurrentUserId();
    final monthYear = _currentMonthYear;

    try {
      // Auto-refresh monthly budget if enabled
      final storage = getIt<CustomSecureStorage>();
      final savedAutoRefresh = await storage.readSecureData(
        'expense_auto_refresh_budget',
      );
      final isAutoRefresh =
          savedAutoRefresh == null || savedAutoRefresh == 'true';

      await ExpenseDatabaseService.instance.checkAndAutoRefreshBudgets(
        userId,
        monthYear,
        isAutoRefresh: isAutoRefresh,
      );

      final expCats = await ExpenseDatabaseService.instance.getCategories(
        userId,
        'expense',
      );
      final incCats = await ExpenseDatabaseService.instance.getCategories(
        userId,
        'income',
      );

      final items = await ExpenseDatabaseService.instance.getTransactions(
        userId,
      );
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
    } catch (e) {
      debugPrint('Error loading expense data: $e');
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

    final userId = await UserHelper.getCurrentUserId();
    final catList = _quickType == 'expense'
        ? _expenseCategories
        : _incomeCategories;
    final selectedCat = catList.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => catList.isNotEmpty
          ? catList.first
          : CategoryModel(id: 'other', name: 'Other', type: _quickType),
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _quickType == 'expense'
                ? AppStrings.quickExpenseLogged
                : AppStrings.quickIncomeAdded,
          ),
          backgroundColor: AppColors.statusSuccess,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showSavingsGoalDialog() async {
    final userId = await UserHelper.getCurrentUserId();
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
    final userId = await UserHelper.getCurrentUserId();
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom:
              AppSizes.bottomNavHeight + MediaQuery.paddingOf(context).bottom,
        ),
        child: _buildFab(scheme),
      ),
      body: GradientBackground(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: scheme.primary))
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
                      _buildTopBar(context, scheme),
                      const SizedBox(height: AppSizes.xl),

                      // First-time Budget prompt banner
                      if (_budgetProgressList.isEmpty) ...[
                        _buildFirstTimeBudgetBanner(scheme),
                        const SizedBox(height: AppSizes.lg),
                      ],

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
                            _selectedCategoryId = list.isNotEmpty
                                ? list.first.id
                                : '';
                          });
                        },
                        onCategoryChanged: (val) =>
                            setState(() => _selectedCategoryId = val),
                        onTrack: _trackQuickTransaction,
                      ),
                      const SizedBox(height: AppSizes.xxl),
                      _buildRecentTransactionsSection(
                        context,
                        currencyFormat,
                        scheme,
                        isLight,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFirstTimeBudgetBanner(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.35),
            scheme.primary.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stars_rounded, color: scheme.onPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.firstIncomePromptTitle,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.firstIncomePromptBody,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.onPrimary,
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _openBudgetScreen,
            child: Text(
              AppStrings.setBudget,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(ColorScheme scheme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [scheme.primary.withValues(alpha: 0.85), scheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RawMaterialButton(
        shape: const CircleBorder(),
        onPressed: _openAddScreen,
        child: Icon(
          Icons.add_rounded,
          color: scheme.onPrimary,
          size: AppSizes.iconXxl,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ColorScheme scheme) {
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
            Text(AppStrings.manageYourSpending, style: AppTextStyles.subtitle),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: scheme.secondary,
                size: AppSizes.iconLg,
              ),
              tooltip: AppStrings.setBudget,
              onPressed: _openBudgetScreen,
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: scheme.secondary,
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
    ColorScheme scheme,
    bool isLight,
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
              color: isLight
                  ? scheme.surfaceContainerHighest
                  : AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: Center(
              child: Text(
                AppStrings.noTransactionsLogged,
                style: TextStyle(
                  color: isLight
                      ? AppColors.lightSecondaryOnSurface
                      : AppColors.secondaryText,
                  fontSize: AppSizes.fontBodySm,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allTransactions.length > 5
                ? 5
                : _allTransactions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.sm + 2),
            itemBuilder: (context, index) {
              return TransactionTile(
                transaction: _allTransactions[index],
                currencyFormat: currencyFormat,
                onEdit: () async {
                  final updated = await context.push<bool>(
                    RouteNames.addExpense,
                    extra: _allTransactions[index],
                  );
                  if (updated == true) _loadAllData();
                },
              );
            },
          ),
      ],
    );
  }
}
