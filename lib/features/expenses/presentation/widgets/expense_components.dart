import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
export 'package:mineai/core/widgets/buttons/app_gradient_button.dart';

/// Segmented Switch: Expense vs Income
class TransactionTypeSwitch extends StatelessWidget {
  final String activeType;
  final ValueChanged<String> onTypeChanged;

  const TransactionTypeSwitch({
    super.key,
    required this.activeType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = activeType == 'expense';
    return Container(
      height: AppSizes.buttonHeightSm,
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          _buildItem(
            label: AppStrings.expenses,
            isSelected: isExpense,
            color: AppColors.expenseRedBg.withValues(alpha: 0.85),
            onTap: () => onTypeChanged('expense'),
          ),
          _buildItem(
            label: AppStrings.income,
            isSelected: !isExpense,
            color: AppColors.incomeGreenBg.withValues(alpha: 0.85),
            onTap: () => onTypeChanged('income'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontBody,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.whiteColor : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Large Amount Input Field
class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final String? Function(String?)? validator;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.accentColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.fontTitleSm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.fontTitleSm),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Text(
            '\$ ',
            style: TextStyle(
              fontSize: AppSizes.fontAmount,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: AppSizes.fontAmount,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Dropdown that strictly emits category.id
class CategoryDropdownField extends StatelessWidget {
  final String selectedCategoryId;
  final List<CategoryModel> categories;
  final ValueChanged<String> onCategoryChanged;

  const CategoryDropdownField({
    super.key,
    required this.selectedCategoryId,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveId = categories.any((c) => c.id == selectedCategoryId)
        ? selectedCategoryId
        : (categories.isNotEmpty ? categories.first.id : null);

    return Container(
      height: AppSizes.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.08),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveId,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: AppSizes.fontBody,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
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
    );
  }
}
