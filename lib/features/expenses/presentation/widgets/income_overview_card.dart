import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';

/// Overview card presenting total income and trend comparison.
class IncomeOverviewCard extends StatelessWidget {
  final double totalIncome;
  final NumberFormat currencyFormat;

  const IncomeOverviewCard({
    super.key,
    required this.totalIncome,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.incomeGreenBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: const BoxDecoration(
                  color: AppColors.incomeGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.incomeGreen,
                  size: AppSizes.iconXs,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.income,
                style: const TextStyle(
                  color: AppColors.incomeGreen,
                  fontSize: AppSizes.fontCaption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            currencyFormat.format(totalIncome),
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: AppSizes.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+12% ${AppStrings.fromLastMonth}',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: AppSizes.fontXs,
            ),
          ),
        ],
      ),
    );
  }
}
