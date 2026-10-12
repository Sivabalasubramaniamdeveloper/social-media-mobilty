import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';

/// Card showing monthly savings goal progress with quick action to edit/add.
class SavingsGoalCard extends StatelessWidget {
  final double? monthlySavingsGoal;
  final double totalBalance;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const SavingsGoalCard({
    super.key,
    required this.monthlySavingsGoal,
    required this.totalBalance,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlySavingsGoal == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.savings_rounded,
                    color: AppColors.accentLavender,
                    size: AppSizes.iconSm,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    '${AppStrings.savingsGoal} (${AppStrings.optional})',
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: AppSizes.fontBodySm,
                    ),
                  ),
                ],
              ),
              Text(
                '+ ${AppStrings.addSavingsGoal}',
                style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: AppSizes.fontCaption,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final goal = monthlySavingsGoal!;
    final savedSoFar = totalBalance > 0 ? totalBalance : 0.0;
    final pct = (savedSoFar / (goal <= 0 ? 1 : goal)).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.savings_rounded,
                      color: AppColors.accentLavender,
                      size: AppSizes.iconSm - 2,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.savingsGoal,
                      style: const TextStyle(
                        color: AppColors.accentLavender,
                        fontSize: AppSizes.fontBodySm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${currencyFormat.format(savedSoFar)} / ${currencyFormat.format(goal)}',
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: AppSizes.fontBodySm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.xs),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.whiteColor.withValues(alpha: 0.1),
                color: AppColors.incomeGreen,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
