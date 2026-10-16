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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    final isExpense = activeType == 'expense';
    return Container(
      height: AppSizes.buttonHeightSm,
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _buildItem(
            label: AppStrings.expenses,
            isSelected: isExpense,
            color: AppColors.expenseRedBg.withValues(alpha: 0.85),
            onTap: () => onTypeChanged('expense'),
            selectedTextColor: scheme.onSurface,
            unselectedTextColor: secondaryText,
          ),
          _buildItem(
            label: AppStrings.income,
            isSelected: !isExpense,
            color: AppColors.incomeGreenBg.withValues(alpha: 0.85),
            onTap: () => onTypeChanged('income'),
            selectedTextColor: scheme.onSurface,
            unselectedTextColor: secondaryText,
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
    required Color selectedTextColor,
    required Color unselectedTextColor,
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
              color: isSelected ? selectedTextColor : unselectedTextColor,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.fontTitleSm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.fontTitleSm),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: AppSizes.fontAmount,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.sampleAmount,
                hintStyle: TextStyle(color: secondaryText),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    final effectiveId = categories.any((c) => c.id == selectedCategoryId)
        ? selectedCategoryId
        : (categories.isNotEmpty ? categories.first.id : null);

    return Container(
      height: AppSizes.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: isLight ? scheme.surfaceContainerHighest : AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveId,
          isExpanded: true,
          dropdownColor: isLight ? scheme.surface : AppColors.surface,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: AppSizes.fontBody,
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: secondaryText),
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
