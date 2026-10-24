import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';

/// Reusable list item tile for a single transaction (income or expense).
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final NumberFormat currencyFormat;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyFormat,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText;

    final isExpense = transaction.type == 'expense';

    return InkWell(
      onTap: onTap ?? onEdit,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.fontBody,
        ),
        decoration: BoxDecoration(
          color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconBoxMd,
              height: AppSizes.iconBoxMd,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseOrangeBg
                    : AppColors.incomeGreenBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                isExpense
                    ? Icons.shopping_bag_outlined
                    : Icons.account_balance_rounded,
                color: isExpense
                    ? AppColors.expenseOrange
                    : AppColors.incomeGreen,
                size: AppSizes.iconSm,
              ),
            ),
            const SizedBox(width: AppSizes.fontBody),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.getCategoryName(transaction.title),
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(transaction.time),
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: AppSizes.fontBody,
                    fontWeight: FontWeight.bold,
                    color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                  ),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(
                    transaction.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      color: secondaryText,
                    ),
                  ),
              ],
            ),
            if (onEdit != null) ...[
              const SizedBox(width: AppSizes.xs),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: secondaryText,
                  size: AppSizes.iconSm,
                ),
                tooltip: AppStrings.edit,
                onPressed: onEdit,
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: AppSizes.xs),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: secondaryText,
                  size: AppSizes.iconSm,
                ),
                tooltip: AppStrings.delete,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
