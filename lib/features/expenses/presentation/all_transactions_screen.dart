import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_text_styles.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/transaction_tile.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:mineai/instance/locator.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final ExpenseRepository _repository = ExpenseRepositoryImpl();

  bool _isLoading = true;
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonth = DateFormat('MM').format(DateTime.now()); // "01" - "12" or "all"
  String _selectedType = 'all'; // 'all', 'expense', 'income'

  List<String> _availableYears = [DateTime.now().year.toString()];
  List<TransactionModel> _transactions = [];

  final List<Map<String, String>> _months = [
    {'code': 'all', 'name': 'All Months'},
    {'code': '01', 'name': 'Jan'},
    {'code': '02', 'name': 'Feb'},
    {'code': '03', 'name': 'Mar'},
    {'code': '04', 'name': 'Apr'},
    {'code': '05', 'name': 'May'},
    {'code': '06', 'name': 'Jun'},
    {'code': '07', 'name': 'Jul'},
    {'code': '08', 'name': 'Aug'},
    {'code': '09', 'name': 'Sep'},
    {'code': '10', 'name': 'Oct'},
    {'code': '11', 'name': 'Nov'},
    {'code': '12', 'name': 'Dec'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<String> _getUserId() async {
    final storage = getIt<CustomSecureStorage>();
    final id = await storage.readSecureData('userId');
    return (id != null && id.isNotEmpty) ? id : 'guest_user';
  }

  Future<void> _initData() async {
    final userId = await _getUserId();
    final years = await ExpenseDatabaseService.instance.getDistinctYears(userId);
    if (mounted) {
      setState(() {
        _availableYears = years.isNotEmpty ? years : [DateTime.now().year.toString()];
        if (!_availableYears.contains(_selectedYear)) {
          _selectedYear = _availableYears.first;
        }
      });
      await _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final userId = await _getUserId();

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

  Future<void> _confirmDelete(TransactionModel tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          AppStrings.deleteTransaction,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${AppStrings.deleteConfirmMsg}\n\n${tx.title} • \$${tx.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppStrings.cancel,
              style: const TextStyle(color: AppColors.secondaryText),
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
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && tx.id != null) {
      await _repository.deleteTransaction(tx.id!, tx.userId);
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
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.md,
              ),
              child: AppScreenHeader(
                title: AppStrings.allTransactions,
                titleSize: AppSizes.fontHeading,
                onBack: () => context.pop(true),
              ),
            ),
            _buildFilterHeader(),
            _buildSummaryRow(totalIncome, totalExpense, currencyFormat),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPurple),
                    )
                  : _transactions.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.noTransactionsForPeriod,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: AppSizes.fontBodySm,
                            ),
                          ),
                        )
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

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Year Dropdown
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: AppColors.whiteColor.withValues(alpha: 0.08),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedYear,
                    dropdownColor: AppColors.surface,
                    style: AppTextStyles.bodyText,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.accentLavender,
                      size: AppSizes.fontTitleSm,
                    ),
                    items: _availableYears
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text(y)),
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
              const SizedBox(width: AppSizes.sm),
              // Type Filter Toggle
              Expanded(
                child: Row(
                  children: [
                    _typeChip('all', AppStrings.all),
                    const SizedBox(width: AppSizes.xs),
                    _typeChip('expense', AppStrings.expenses),
                    const SizedBox(width: AppSizes.xs),
                    _typeChip('income', AppStrings.income),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          // Horizontal Months Selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _months.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSizes.xs),
              itemBuilder: (context, index) {
                final m = _months[index];
                final isSelected = _selectedMonth == m['code'];
                return ChoiceChip(
                  label: Text(
                    m['name']!,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: isSelected
                          ? AppColors.whiteColor
                          : AppColors.secondaryText,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryPurple,
                  backgroundColor: AppColors.surfaceDeep,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedMonth = m['code']!);
                      _loadTransactions();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedType = type);
          _loadTransactions();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple.withValues(alpha: 0.25)
                : AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.whiteColor.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontCaption,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.whiteColor : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    double totalIncome,
    double totalExpense,
    NumberFormat currencyFormat,
  ) {
    final balance = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.xs,
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            AppStrings.income,
            '+${currencyFormat.format(totalIncome)}',
            AppColors.incomeGreen,
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.whiteColor.withValues(alpha: 0.1),
          ),
          _summaryItem(
            AppStrings.expenses,
            '-${currencyFormat.format(totalExpense)}',
            AppColors.expenseRed,
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.whiteColor.withValues(alpha: 0.1),
          ),
          _summaryItem(
            AppStrings.totalBalance,
            currencyFormat.format(balance),
            balance >= 0 ? AppColors.whiteColor : AppColors.expenseRed,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontXs,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontCaption,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
