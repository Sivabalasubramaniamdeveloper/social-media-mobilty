import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_text_styles.dart';

/// Hero summary card displaying Total Balance, Income, and Expenses totals.
class BalanceOverviewCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final NumberFormat currencyFormat;
  final VoidCallback onWalletTap;

  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currencyFormat,
    required this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.totalBalance,
                    style: AppTextStyles.eyebrow,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    currencyFormat.format(totalBalance),
                    style: TextStyle(
                      fontSize: AppSizes.fontDisplay,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onWalletTap,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Container(
                  width: 56,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.accentLavender,
                    size: AppSizes.iconXl,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Row(
            children: [
              _buildMetricItem(
                label: AppStrings.income,
                amount: currencyFormat.format(totalIncome),
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.incomeGreen,
                iconBgColor: AppColors.incomeGreenBg.withValues(alpha: 0.5),
              ),
              const SizedBox(width: AppSizes.xxxl),
              _buildMetricItem(
                label: AppStrings.expenses,
                amount: currencyFormat.format(totalExpenses),
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.expenseRed,
                iconBgColor: AppColors.expenseRedBg.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Row(
      children: [
        Container(
          width: AppSizes.xxl + AppSizes.sm,
          height: AppSizes.xxl + AppSizes.sm,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: AppSizes.iconSm - 4),
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.micro),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
