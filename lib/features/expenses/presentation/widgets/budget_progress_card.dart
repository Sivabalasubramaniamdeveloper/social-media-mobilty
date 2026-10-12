import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';

/// Reusable card displaying budget limits vs actual spent per category.
class BudgetProgressCard extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final List<BudgetProgressItemModel> items;
  final NumberFormat currencyFormat;
  final int? maxDisplayCount;
  final VoidCallback? onViewAllTap;

  const BudgetProgressCard({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    required this.items,
    required this.currencyFormat,
    this.maxDisplayCount,
    this.onViewAllTap,
  });

  /// Factory from repository `BudgetProgress` list
  factory BudgetProgressCard.fromProgressList({
    Key? key,
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required List<BudgetProgress> list,
    required NumberFormat currencyFormat,
    int? maxDisplayCount,
    VoidCallback? onViewAllTap,
  }) {
    return BudgetProgressCard(
      key: key,
      title: title,
      actionText: actionText,
      onActionTap: onActionTap,
      currencyFormat: currencyFormat,
      maxDisplayCount: maxDisplayCount,
      onViewAllTap: onViewAllTap,
      items: list.map((bp) {
        return BudgetProgressItemModel(
          categoryId: bp.category.id,
          categoryName: bp.category.name,
          spent: bp.spent,
          allocated: bp.budget.allocatedAmount,
          percentage: bp.percentage,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = maxDisplayCount != null
        ? items.take(maxDisplayCount!).toList()
        : items;

    final hasMore = maxDisplayCount != null && items.length > maxDisplayCount!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusHeading),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.fontSubheading,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
              if (actionText != null && onActionTap != null)
                InkWell(
                  onTap: onActionTap,
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      fontSize: AppSizes.fontCaption,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentLavender,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: TextButton.icon(
                  onPressed: onActionTap,
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primaryPurple,
                    size: AppSizes.fontTitleSm,
                  ),
                  label: Text(
                    AppStrings.noBudgetSet,
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: AppSizes.fontBodySm,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            ...displayItems.map((item) => _buildItemRow(item)),
            if (hasMore && onViewAllTap != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onViewAllTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${AppStrings.seeAll} (${items.length})',
                    style: const TextStyle(
                      color: AppColors.accentLavender,
                      fontSize: AppSizes.fontCaption,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(BudgetProgressItemModel item) {
    final pct = (item.percentage / 100).clamp(0.0, 1.0);
    final isExceeded = item.percentage >= 100;
    final isCritical = item.percentage >= 90;

    final barColor = isExceeded
        ? AppColors.statusCritical
        : isCritical
            ? AppColors.statusWarning
            : AppColors.primaryPurple;

    final statusText = isExceeded
        ? AppStrings.budgetExceeded
        : isCritical
            ? '${AppStrings.almostReachedLimit} (${item.percentage.toStringAsFixed(0)}% ${AppStrings.used})'
            : '${AppStrings.onTrack} (${item.percentage.toStringAsFixed(0)}% ${AppStrings.used})';

    final statusColor = isExceeded
        ? AppColors.statusCritical
        : isCritical
            ? AppColors.statusWarning
            : AppColors.statusSuccess;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.getCategoryName(item.categoryName),
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: AppSizes.fontBodySm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${currencyFormat.format(item.spent)} / ${currencyFormat.format(item.allocated)}',
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: AppSizes.fontCaption,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.xs),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: AppColors.whiteColor.withValues(alpha: 0.1),
              color: barColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetProgressItemModel {
  final String categoryId;
  final String categoryName;
  final double spent;
  final double allocated;
  final double percentage;

  const BudgetProgressItemModel({
    required this.categoryId,
    required this.categoryName,
    required this.spent,
    required this.allocated,
    required this.percentage,
  });
}
