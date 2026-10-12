import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/widgets/cards/app_list_tile_card.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/instance/locator.dart';

class ExpenseSettingsScreen extends StatefulWidget {
  const ExpenseSettingsScreen({super.key});

  @override
  State<ExpenseSettingsScreen> createState() => _ExpenseSettingsScreenState();
}

class _ExpenseSettingsScreenState extends State<ExpenseSettingsScreen> {
  bool _budgetAlerts = true;
  int _totalTransactionsCount = 0;
  int _activeBudgetsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<String> _getUserId() async {
    final storage = getIt<CustomSecureStorage>();
    final id = await storage.readSecureData('userId');
    return (id != null && id.isNotEmpty) ? id : 'guest_user';
  }

  Future<void> _loadStats() async {
    final userId = await _getUserId();
    final monthYear = DateFormat('yyyy-MM').format(DateTime.now());

    final txList = await ExpenseDatabaseService.instance.getTransactions(userId);
    final budgets = await ExpenseDatabaseService.instance.getAllBudgets(
      userId,
      monthYear,
    );

    if (mounted) {
      setState(() {
        _totalTransactionsCount = txList.length;
        _activeBudgetsCount = budgets.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required Future<void> Function() onConfirmed,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
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
              AppStrings.confirm,
              style: const TextStyle(
                color: AppColors.whiteColor,
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
        _loadStats();
      }
    }
  }

  Future<void> _clearTransactions() async {
    await _confirmAction(
      title: AppStrings.clearTransactions,
      message: AppStrings.clearTransactionsConfirm,
      onConfirmed: () async {
        final userId = await _getUserId();
        await ExpenseDatabaseService.instance.clearAllTransactions(userId);
      },
    );
  }

  Future<void> _resetBudgets() async {
    await _confirmAction(
      title: AppStrings.resetBudgets,
      message: 'Are you sure you want to reset all category budgets for this month?',
      onConfirmed: () async {
        final userId = await _getUserId();
        await ExpenseDatabaseService.instance.clearAllBudgets(userId);
      },
    );
  }

  Future<void> _clearAllData() async {
    await _confirmAction(
      title: AppStrings.clearAllData,
      message: AppStrings.clearDataConfirm,
      onConfirmed: () async {
        final userId = await _getUserId();
        await ExpenseDatabaseService.instance.clearAllExpenseData(userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                title: AppStrings.expenseSettings,
                titleSize: AppSizes.fontHeading,
                onBack: () => context.pop(true),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPurple),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.pagePadding,
                        vertical: AppSizes.md,
                      ),
                      children: [
                        _buildStatsSummary(),
                        const SizedBox(height: AppSizes.xxl),
                        AppSectionHeader(
                          title: AppStrings.preferences,
                          isEyebrow: true,
                        ),
                        AppListTileCard.toggle(
                          icon: Icons.notifications_active_outlined,
                          title: AppStrings.budgetAlertToggle,
                          value: _budgetAlerts,
                          onChanged: (val) => setState(() => _budgetAlerts = val),
                        ),
                        AppListTileCard(
                          icon: Icons.tune_rounded,
                          title: AppStrings.manageBudgets,
                          subtitle: 'Configure monthly limits',
                          onTap: () async {
                            await context.push(RouteNames.incomeBudget);
                            _loadStats();
                          },
                        ),
                        const SizedBox(height: AppSizes.xxl),
                        AppSectionHeader(
                          title: 'DATA MANAGEMENT',
                          isEyebrow: true,
                        ),
                        AppListTileCard(
                          icon: Icons.delete_sweep_outlined,
                          title: AppStrings.clearTransactions,
                          subtitle: 'Delete all logged transactions',
                          onTap: _clearTransactions,
                        ),
                        AppListTileCard(
                          icon: Icons.restart_alt_rounded,
                          title: AppStrings.resetBudgets,
                          subtitle: 'Reset category allocations to zero',
                          onTap: _resetBudgets,
                        ),
                        AppListTileCard(
                          icon: Icons.warning_amber_rounded,
                          title: AppStrings.clearAllData,
                          subtitle: 'Clear all transactions, budgets & goals',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.statusCritical,
                          ),
                          onTap: _clearAllData,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol('Logged Transactions', '$_totalTransactionsCount'),
          Container(
            width: 1,
            height: 36,
            color: AppColors.whiteColor.withValues(alpha: 0.1),
          ),
          _statCol('Active Budgets', '$_activeBudgetsCount'),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: AppSizes.fontTitleSm,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: AppSizes.fontXs,
          ),
        ),
      ],
    );
  }
}
