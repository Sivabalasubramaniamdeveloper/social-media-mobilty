import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_text_styles.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/features/expenses/models/budget_model.dart';
import 'package:mineai/features/expenses/models/category_model.dart';

/// Modal dialog for creating or updating a category budget limit.
class SetBudgetDialog extends StatefulWidget {
  final String userId;
  final String monthYear;
  final String? initialCategoryId;
  final double? initialAmount;
  final VoidCallback onSaved;

  const SetBudgetDialog({
    super.key,
    required this.userId,
    required this.monthYear,
    this.initialCategoryId,
    this.initialAmount,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String monthYear,
    String? initialCategoryId,
    double? initialAmount,
    required VoidCallback onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SetBudgetDialog(
        userId: userId,
        monthYear: monthYear,
        initialCategoryId: initialCategoryId,
        initialAmount: initialAmount,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  final TextEditingController _amountController = TextEditingController();
  List<CategoryModel> _categories = [];
  String _selectedCategoryId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(0);
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await ExpenseDatabaseService.instance.getCategories(
      widget.userId,
      'expense',
    );
    if (mounted) {
      setState(() {
        _categories = cats;
        _selectedCategoryId = widget.initialCategoryId ??
            (cats.isNotEmpty ? cats.first.id : '');
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    final amt = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.enterValidBudget),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final budget = BudgetModel(
      userId: widget.userId,
      categoryId: _selectedCategoryId,
      allocatedAmount: amt,
      monthYear: widget.monthYear,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ExpenseDatabaseService.instance.saveOrUpdateBudget(budget);
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        AppStrings.setOrEditBudget,
        style: const TextStyle(
          color: AppColors.whiteColor,
          fontSize: AppSizes.fontTitleSm,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.category,
                  style: TextStyle(
                    fontSize: AppSizes.fontBodySm,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  height: AppSizes.buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: AppColors.whiteColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categories.any((c) => c.id == _selectedCategoryId)
                          ? _selectedCategoryId
                          : (_categories.isNotEmpty ? _categories.first.id : null),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondaryText,
                      ),
                      dropdownColor: AppColors.surface,
                      style: AppTextStyles.bodyText,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategoryId = val);
                      },
                      items: _categories
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
                const SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.allocatedLimitCurrency,
                  style: TextStyle(
                    fontSize: AppSizes.fontBodySm,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: AppColors.whiteColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: AppSizes.fontSubheading,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontSubheading,
                      ),
                      hintText: AppStrings.sampleBudgetAmount,
                      hintStyle: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: AppSizes.fontBodyLg,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppStrings.cancel,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),
          onPressed: _saveBudget,
          child: Text(
            AppStrings.saveBudget,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
