import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/transaction_tile.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:mineai/features/expenses/services/expense_export_service.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final ExpenseRepository _repository = ExpenseRepositoryImpl();

  bool _isLoading = true;
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonth = DateFormat(
    'MM',
  ).format(DateTime.now()); // "01" - "12" or "all"
  String _selectedType = 'all'; // 'all', 'expense', 'income'

  List<String> _availableYears = [DateTime.now().year.toString()];
  List<TransactionModel> _transactions = [];

  final List<Map<String, String>> _months = [
    {'code': 'all', 'name': 'All Months'},
    {'code': '01', 'name': 'January'},
    {'code': '02', 'name': 'February'},
    {'code': '03', 'name': 'March'},
    {'code': '04', 'name': 'April'},
    {'code': '05', 'name': 'May'},
    {'code': '06', 'name': 'June'},
    {'code': '07', 'name': 'July'},
    {'code': '08', 'name': 'August'},
    {'code': '09', 'name': 'September'},
    {'code': '10', 'name': 'October'},
    {'code': '11', 'name': 'November'},
    {'code': '12', 'name': 'December'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userId = await UserHelper.getCurrentUserId();
    final years = await ExpenseDatabaseService.instance.getDistinctYears(
      userId,
    );
    if (mounted) {
      setState(() {
        _availableYears = years.isNotEmpty
            ? years
            : [DateTime.now().year.toString()];
        if (!_availableYears.contains(_selectedYear)) {
          _selectedYear = _availableYears.first;
        }
      });
      await _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final userId = await UserHelper.getCurrentUserId();

    final monthYear = _selectedMonth == 'all'
        ? null
        : '$_selectedYear-$_selectedMonth';
    final year = _selectedMonth == 'all' ? _selectedYear : null;

    final list = await _repository.getTransactionsFiltered(
      userId,
      monthYear: monthYear,
      year: year,
      type: _selectedType,
    );

    if (mounted) {
      setState(() {
        _transactions = list;
        _isLoading = false;
      });
    }
  }

  String _getSelectedPeriodLabel() {
    final monthName = _months.firstWhere(
      (m) => m['code'] == _selectedMonth,
      orElse: () => {'name': _selectedMonth},
    )['name'];
    return '$_selectedYear • $monthName';
  }

  Future<void> _confirmDelete(TransactionModel tx) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? scheme.surface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          AppStrings.deleteTransaction,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${AppStrings.deleteConfirmMsg}\n\n${tx.title} • \$${tx.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isLight
                ? AppColors.lightSecondaryOnSurface
                : AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCritical,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.delete,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && tx.id != null) {
      final userId = await UserHelper.getCurrentUserId();
      await _repository.deleteTransaction(tx.id!, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.transactionDeleted),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
        _loadTransactions();
      }
    }
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

    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in _transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppScreenHeader(
                      title: AppStrings.allTransactions,
                      titleSize: AppSizes.fontHeading,
                      onBack: () => context.pop(true),
                    ),
                  ),
                  // Export Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ExpenseExportService.showExportBottomSheet(
                          context: context,
                          transactions: _transactions,
                          periodTitle: _getSelectedPeriodLabel(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.download_rounded,
                              color: scheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.export,
                              style: TextStyle(
                                color: scheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown Filter Header
            _buildFilterHeader(scheme, isLight),

            // Summary Stats Card
            _buildSummaryRow(
              totalIncome,
              totalExpense,
              currencyFormat,
              scheme,
              isLight,
            ),

            const SizedBox(height: AppSizes.sm),

            // Transactions List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    )
                  : _transactions.isEmpty
                  ? _buildEmptyState(scheme, isLight)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePadding,
                        vertical: AppSizes.md,
                      ),
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSizes.sm + 2),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return TransactionTile(
                          transaction: tx,
                          currencyFormat: currencyFormat,
                          onEdit: () async {
                            final updated = await context.push<bool>(
                              RouteNames.addExpense,
                              extra: tx,
                            );
                            if (updated == true) _loadTransactions();
                          },
                          onDelete: () => _confirmDelete(tx),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(ColorScheme scheme, bool isLight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // Row with Year Dropdown and Month Dropdown side-by-side
          Row(
            children: [
              // Year Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isLight ? scheme.surface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      dropdownColor: isLight
                          ? scheme.surface
                          : const Color(0xFF1B192E),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.secondary,
                        size: 20,
                      ),
                      items: _availableYears
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: scheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(y),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedYear = val);
                          _loadTransactions();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Month Dropdown (Replaces horizontal chips)
              Expanded(
                flex: 3,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isLight ? scheme.surface : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      isExpanded: true,
                      dropdownColor: isLight
                          ? scheme.surface
                          : const Color(0xFF1B192E),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.secondary,
                        size: 20,
                      ),
                      items: _months
                          .map(
                            (m) => DropdownMenuItem(
                              value: m['code'],
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_note_rounded,
                                    size: 14,
                                    color: scheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      m['name']!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMonth = val);
                          _loadTransactions();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Type Segmented Filter (All, Expenses, Income)
          Row(
            children: [
              _typeButton('all', AppStrings.all, scheme),
              const SizedBox(width: 6),
              _typeButton('expense', AppStrings.expenses, scheme),
              const SizedBox(width: 6),
              _typeButton('income', AppStrings.income, scheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String type, String label, ColorScheme scheme) {
    final isSelected = _selectedType == type;
    Color activeColor = scheme.primary;
    if (type == 'expense') activeColor = AppColors.expenseRed;
    if (type == 'income') activeColor = AppColors.incomeGreen;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedType = type);
          _loadTransactions();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : scheme.onSurface.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? scheme.onSurface
                    : (Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryOnSurface
                          : AppColors.secondaryText),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    double income,
    double expense,
    NumberFormat currencyFormat,
    ColorScheme scheme,
    bool isLight,
  ) {
    final net = income - expense;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        12,
        AppSizes.pagePadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight
              ? scheme.surfaceContainerHighest
              : AppColors.surfaceDeep,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem(
              'Income',
              currencyFormat.format(income),
              AppColors.incomeGreen,
              Icons.arrow_downward_rounded,
              scheme,
              isLight,
            ),
            Container(
              width: 1,
              height: 32,
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
            _summaryItem(
              'Expense',
              currencyFormat.format(expense),
              AppColors.expenseRed,
              Icons.arrow_upward_rounded,
              scheme,
              isLight,
            ),
            Container(
              width: 1,
              height: 32,
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
            _summaryItem(
              'Net',
              currencyFormat.format(net),
              net >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
              Icons.account_balance_wallet_outlined,
              scheme,
              isLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String amount,
    Color color,
    IconData icon,
    ColorScheme scheme,
    bool isLight,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
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
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, bool isLight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noTransactionsFound,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.noTransactionsFor(_getSelectedPeriodLabel()),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLight
                    ? AppColors.lightSecondaryOnSurface
                    : AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(Icons.add_rounded, color: scheme.onPrimary),
              label: Text(
                AppStrings.addTransaction,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final res = await context.push(RouteNames.addExpense);
                if (res == true) _loadTransactions();
              },
            ),
          ],
        ),
      ),
    );
  }
}
