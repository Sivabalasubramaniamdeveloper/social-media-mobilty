import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/expenses/models/category_model.dart';

/// Quick logging widget for instant expense or income capture.
class QuickTrackSection extends StatelessWidget {
  final TextEditingController amountController;
  final String quickType;
  final String selectedCategoryId;
  final List<CategoryModel> categories;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onTrack;

  const QuickTrackSection({
    super.key,
    required this.amountController,
    required this.quickType,
    required this.selectedCategoryId,
    required this.categories,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = quickType == 'expense';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.quickTrack,
              style: TextStyle(
                fontSize: AppSizes.fontSubheading,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: Text(AppStrings.expenses),
                  selected: isExpense,
                  onSelected: (val) {
                    if (val) onTypeChanged('expense');
                  },
                  selectedColor: AppColors.expenseRedBg,
                  labelStyle: TextStyle(
                    fontSize: AppSizes.fontCaption,
                    color: isExpense ? AppColors.whiteColor : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                ChoiceChip(
                  label: Text(AppStrings.income),
                  selected: !isExpense,
                  onSelected: (val) {
                    if (val) onTypeChanged('income');
                  },
                  selectedColor: AppColors.incomeGreenBg,
                  labelStyle: TextStyle(
                    fontSize: AppSizes.fontCaption,
                    color: !isExpense ? AppColors.whiteColor : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md + 2),
        Container(
          height: AppSizes.buttonHeight + 2,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg + 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceDeep,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Text(
                '\$ ',
                style: TextStyle(
                  fontSize: AppSizes.fontTitleSm,
                  fontWeight: FontWeight.w600,
                  color: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: AppSizes.fontSubheading,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: AppSizes.fontSubheading,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md + 2),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: AppSizes.buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md + 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.whiteColor.withValues(alpha: 0.06),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: categories.any((c) => c.id == selectedCategoryId)
                        ? selectedCategoryId
                        : (categories.isNotEmpty ? categories.first.id : null),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.secondaryText,
                    ),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: AppSizes.fontBodySm,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (val) {
                      if (val != null) onCategoryChanged(val);
                    },
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(AppStrings.getCategoryName(c.name)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              flex: 5,
              child: SizedBox(
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpense
                        ? AppColors.primaryPurpleDeep
                        : AppColors.incomeGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isExpense ? AppStrings.trackIt : AppStrings.submit,
                    style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
