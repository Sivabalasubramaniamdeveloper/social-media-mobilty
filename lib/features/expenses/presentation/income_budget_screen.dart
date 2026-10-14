import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = await UserHelper.getCurrentUserId();
    final monthYear = _currentMonthYear;

    // Check auto-refresh setting and auto-refresh if applicable
    final storage = getIt<CustomSecureStorage>();
    final savedAutoRefresh =
        await storage.readSecureData('expense_auto_refresh_budget');
    final isAutoRefresh =
        savedAutoRefresh == null || savedAutoRefresh == 'true';

    final userBudgets = await ExpenseDatabaseService.instance
        .checkAndAutoRefreshBudgets(
      userId,
      monthYear,
      isAutoRefresh: isAutoRefresh,
    );

    final allTx = await ExpenseDatabaseService.instance.getTransactions(userId);

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

    final userId = await UserHelper.getCurrentUserId();

    final tx = TransactionModel(
      userId: userId,
      title: _selectedIncomeSource,
      amount: amount,
      type: 'income',
      categoryId: _selectedIncomeSource.toLowerCase().replaceAll(' ', '_'),
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Income logged successfully!'),
          backgroundColor: AppColors.statusSuccess,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showSetBudgetDialog() async {
    final userId = await UserHelper.getCurrentUserId();
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
        categoryName: b.categoryId.replaceAll('_', ' '),
        spent: spent,
        allocated: b.allocatedAmount,
        percentage: pct,
      );
    }).toList();

    double totalAllocated = 0.0;
    double totalSpent = 0.0;
    for (var b in budgetItems) {
      totalAllocated += b.allocated;
      totalSpent += b.spent;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: scheme.primary,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      title: AppStrings.incomeAndBudget,
                      titleSize: AppSizes.fontHeading,
                      onBack: () => context.pop(true),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: scheme.secondary,
                            size: 22,
                          ),
                          tooltip: AppStrings.setBudget,
                          onPressed: _showSetBudgetDialog,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // First-time / No Budget Banner
                    if (_budgets.isEmpty) ...[
                      _buildNoBudgetBanner(scheme),
                      const SizedBox(height: AppSizes.lg),
                    ],

                    // Top Financial Summary Card
                    _buildOverviewCard(currencyFormat, totalAllocated, totalSpent, scheme, isLight),
                    const SizedBox(height: AppSizes.xl),

                    // Income Logger Card
                    IncomeEntryCard(
                      amountController: _amountController,
                      noteController: _noteController,
                      selectedSource: _selectedIncomeSource,
                      sourceOptions: _incomeSources,
                      selectedDate: _selectedDate,
                      onSourceChanged: (val) {
                        setState(() => _selectedIncomeSource = val);
                      },
                      onDateChanged: (val) => setState(() => _selectedDate = val),
                      onSubmit: _addIncome,
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // Category Budgets Header & List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppSectionHeader(
                          title: AppStrings.monthlyBudget,
                          isEyebrow: true,
                        ),
                        TextButton.icon(
                          onPressed: _showSetBudgetDialog,
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: Text(
                            _budgets.isEmpty ? 'Set Budget' : 'Edit Budgets',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),

                    if (budgetItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: scheme.secondary,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Budgets Set For This Month',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Establish spending boundaries for categories to monitor progress.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _showSetBudgetDialog,
                              child: const Text('Set Monthly Budget Now'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: budgetItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) {
                          final item = budgetItems[index];
                          return _buildBudgetProgressCard(item, currencyFormat, scheme, isLight);
                        },
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNoBudgetBanner(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.35),
            AppColors.primaryPurpleLight.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Step: Set Your Monthly Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Before logging expenses, specify monthly budget limits for your categories.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _showSetBudgetDialog,
            child: const Text(
              'Set Now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    NumberFormat currencyFormat,
    double totalAllocated,
    double totalSpent,
    ColorScheme scheme,
    bool isLight,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINANCIAL OVERVIEW',
                style: TextStyle(
                  color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  color: scheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _overviewStat(
                'Total Income',
                currencyFormat.format(_totalIncome),
                AppColors.incomeGreen,
                Icons.arrow_downward_rounded,
                isLight,
              ),
              _overviewStat(
                'Total Budget',
                currencyFormat.format(totalAllocated),
                scheme.secondary,
                Icons.tune_rounded,
                isLight,
              ),
              _overviewStat(
                'Total Spent',
                currencyFormat.format(totalSpent),
                AppColors.expenseRed,
                Icons.arrow_upward_rounded,
                isLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(
    String label,
    String amount,
    Color color,
    IconData icon,
    bool isLight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgressCard(
    BudgetProgressItemModel item,
    NumberFormat currencyFormat,
    ColorScheme scheme,
    bool isLight,
  ) {
    final pct = item.percentage.clamp(0.0, 100.0);
    final isOver = item.spent > item.allocated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOver
              ? AppColors.expenseRed.withValues(alpha: 0.3)
              : scheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.categoryName,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isOver ? AppColors.expenseRed : AppColors.incomeGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100.0,
              minHeight: 8,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppColors.expenseRed : AppColors.incomeGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${currencyFormat.format(item.spent)}',
                style: TextStyle(
                  color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              Text(
                'Limit: ${currencyFormat.format(item.allocated)}',
                style: TextStyle(
                  color: isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
