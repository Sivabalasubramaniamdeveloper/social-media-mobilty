import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/cards/app_list_tile_card.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/services/expense_export_service.dart';
import 'package:mineai/instance/locator.dart';

class ExpenseSettingsScreen extends StatefulWidget {
  const ExpenseSettingsScreen({super.key});

  @override
  State<ExpenseSettingsScreen> createState() => _ExpenseSettingsScreenState();
}

class _ExpenseSettingsScreenState extends State<ExpenseSettingsScreen> {
  static const String _autoRefreshKey = 'expense_auto_refresh_budget';

  bool _budgetAlerts = true;
  bool _autoRefreshMonthlyBudget = true;
  int _totalTransactionsCount = 0;
  int _activeBudgetsCount = 0;
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndStats();
  }

  Future<void> _loadSettingsAndStats() async {
    final userId = await UserHelper.getCurrentUserId();
    final monthYear = DateFormat('yyyy-MM').format(DateTime.now());

    // Load auto-refresh preference from storage
    final storage = getIt<CustomSecureStorage>();
    final savedAutoRefresh = await storage.readSecureData(_autoRefreshKey);
    final autoRefresh = savedAutoRefresh == null || savedAutoRefresh == 'true';

    final txList = await ExpenseDatabaseService.instance.getTransactions(
      userId,
    );
    final budgets = await ExpenseDatabaseService.instance.getAllBudgets(
      userId,
      monthYear,
    );

    if (mounted) {
      setState(() {
        _autoRefreshMonthlyBudget = autoRefresh;
        _totalTransactionsCount = txList.length;
        _activeBudgetsCount = budgets.length;
        _allTransactions = txList;
        _isLoading = false;
      });
    }
  }

  Future<void> _onAutoRefreshChanged(bool value) async {
    setState(() => _autoRefreshMonthlyBudget = value);
    final storage = getIt<CustomSecureStorage>();
    await storage.writeSecureData(_autoRefreshKey, value ? 'true' : 'false');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? AppStrings.autoRefreshBudgetEnabled
                : AppStrings.manualBudgetModeEnabled,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyPreviousMonthBudgetNow() async {
    final userId = await UserHelper.getCurrentUserId();
    final currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());

    final count = await ExpenseDatabaseService.instance
        .copyBudgetsFromPreviousMonth(userId, currentMonthYear);

    if (!mounted) return;
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.copiedCategoryBudgets(count)),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
      _loadSettingsAndStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noPreviousBudgets),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<void> Function() onConfirmed,
  }) async {
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
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
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
              AppStrings.confirm,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await onConfirmed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.dataClearedSuccess),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
        _loadSettingsAndStats();
      }
    }
  }

  Future<void> _clearTransactions() async {
    await _confirmAction(
      title: AppStrings.clearTransactions,
      message: AppStrings.clearTransactionsConfirm,
      onConfirmed: () async {
        final userId = await UserHelper.getCurrentUserId();
        await ExpenseDatabaseService.instance.clearAllTransactions(userId);
      },
    );
  }

  Future<void> _resetBudgets() async {
    await _confirmAction(
      title: AppStrings.resetBudgets,
      message: AppStrings.resetBudgetsConfirm,
      onConfirmed: () async {
        final userId = await UserHelper.getCurrentUserId();
        await ExpenseDatabaseService.instance.clearAllBudgets(userId);
      },
    );
  }

  Future<void> _clearAllData() async {
    await _confirmAction(
      title: AppStrings.clearAllData,
      message: AppStrings.clearDataConfirm,
      onConfirmed: () async {
        final userId = await UserHelper.getCurrentUserId();
        await ExpenseDatabaseService.instance.clearAllExpenseData(userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

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
              child: AppScreenHeader(
                title: AppStrings.expenseSettings,
                titleSize: AppSizes.fontHeading,
                onBack: () => context.pop(true),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: scheme.primary),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePadding,
                        vertical: AppSizes.md,
                      ),
                      children: [
                        _buildStatsSummary(scheme, isLight),
                        const SizedBox(height: AppSizes.xxl),

                        // Section 1: Monthly Budget & Rollover
                        AppSectionHeader(
                          title: AppStrings.monthlyBudgetSettings,
                          isEyebrow: true,
                        ),
                        AppListTileCard.toggle(
                          icon: Icons.autorenew_rounded,
                          title: AppStrings.autoRefreshMonthlyBudget,
                          subtitle: _autoRefreshMonthlyBudget
                              ? AppStrings.autoRefreshBudgetEnabled
                              : AppStrings.manualBudgetModeEnabled,
                          value: _autoRefreshMonthlyBudget,
                          onChanged: _onAutoRefreshChanged,
                        ),
                        AppListTileCard(
                          icon: Icons.copy_all_rounded,
                          title: AppStrings.copyPreviousBudget,
                          subtitle: AppStrings.copyPreviousBudgetDescription,
                          onTap: _copyPreviousMonthBudgetNow,
                        ),
                        AppListTileCard(
                          icon: Icons.tune_rounded,
                          title: AppStrings.manageBudgets,
                          subtitle: AppStrings.configureCurrentMonthLimits,
                          onTap: () async {
                            await context.push(RouteNames.incomeBudget);
                            _loadSettingsAndStats();
                          },
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        // Section 2: Preferences & Alerts
                        AppSectionHeader(
                          title: AppStrings.preferences,
                          isEyebrow: true,
                        ),
                        AppListTileCard.toggle(
                          icon: Icons.notifications_active_outlined,
                          title: AppStrings.budgetAlertToggle,
                          subtitle: AppStrings.budgetAlertsDescription,
                          value: _budgetAlerts,
                          onChanged: (val) =>
                              setState(() => _budgetAlerts = val),
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        // Section 3: Data Export
                        AppSectionHeader(
                          title: AppStrings.downloadAndExport,
                          isEyebrow: true,
                        ),
                        AppListTileCard(
                          icon: Icons.picture_as_pdf_outlined,
                          title: AppStrings.downloadExpensePdf,
                          subtitle: AppStrings.expensePdfDescription,
                          onTap: () {
                            ExpenseExportService.instance.exportToPdf(
                              context: context,
                              transactions: _allTransactions,
                              periodTitle: AppStrings.allLoggedRecords,
                            );
                          },
                        ),
                        AppListTileCard(
                          icon: Icons.table_chart_outlined,
                          title: AppStrings.downloadExpenseExcel,
                          subtitle: AppStrings.expenseExcelDescription,
                          onTap: () {
                            ExpenseExportService.instance.exportToExcel(
                              context: context,
                              transactions: _allTransactions,
                              periodTitle: AppStrings.allLoggedRecords,
                            );
                          },
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        // Section 4: Data Management
                        AppSectionHeader(
                          title: AppStrings.dataManagement,
                          isEyebrow: true,
                        ),
                        AppListTileCard(
                          icon: Icons.delete_sweep_outlined,
                          title: AppStrings.clearTransactions,
                          subtitle: AppStrings.deleteLoggedTransactions,
                          onTap: _clearTransactions,
                        ),
                        AppListTileCard(
                          icon: Icons.restart_alt_rounded,
                          title: AppStrings.resetBudgets,
                          subtitle: AppStrings.resetCategoryAllocations,
                          onTap: _resetBudgets,
                        ),
                        AppListTileCard(
                          icon: Icons.warning_amber_rounded,
                          title: AppStrings.clearAllData,
                          subtitle: AppStrings.clearAllFinancialData,
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.statusCritical,
                          ),
                          onTap: _clearAllData,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(ColorScheme scheme, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol(
            AppStrings.loggedTransactions,
            '$_totalTransactionsCount',
            Icons.receipt_long_rounded,
            scheme.primary,
            scheme,
            isLight,
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onSurface.withValues(alpha: 0.1),
          ),
          _statCol(
            AppStrings.activeBudgets,
            '$_activeBudgetsCount',
            Icons.account_balance_wallet_rounded,
            AppColors.incomeGreen,
            scheme,
            isLight,
          ),
        ],
      ),
    );
  }

  Widget _statCol(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme scheme,
    bool isLight,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
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
      ],
    );
  }
}
