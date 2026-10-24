import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/animations/app_lottie_view.dart';
import 'package:mineai/features/expenses/models/budget_model.dart';
import 'package:mineai/features/expenses/models/category_model.dart';

/// Attractive, animated modal dialog for setting or adjusting category budgets.
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
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SetBudget',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) => SetBudgetDialog(
        userId: userId,
        monthYear: monthYear,
        initialCategoryId: initialCategoryId,
        initialAmount: initialAmount,
        onSaved: onSaved,
      ),
      transitionBuilder: (ctx, anim, anim2, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(0);
    }
    _amountController.addListener(() => setState(() {}));
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

  void _addAmount(double delta) {
    final current =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final total = current + delta;
    _amountController.text = total.toStringAsFixed(0);
  }

  Future<void> _saveBudget() async {
    final amt = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amt == null || amt <= 0) {
      SnackBarHelper.showWarning(context, AppStrings.enterValidBudget);
      return;
    }

    setState(() => _isSaving = true);
    try {
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatMonthYear(String my) {
    try {
      final parts = my.split('-');
      if (parts.length == 2) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('MMMM yyyy').format(dt);
      }
    } catch (_) {}
    return my;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final enteredAmount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0.0;
    final dailyAllowance = enteredAmount > 0 ? (enteredAmount / 30).toStringAsFixed(0) : '0';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1E1B38),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isLight
                ? scheme.outlineVariant.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryPurple),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with Glowing Icon & Month Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const AppLottieView(
                              type: LottieAnimationType.walletFinance,
                              width: 38,
                              height: 38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.setOrEditBudget,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatMonthYear(widget.monthYear),
                                style: TextStyle(
                                  color: scheme.onSurface.withValues(alpha: 0.55),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Category Selector Dropdown
                  Text(
                    AppStrings.category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isLight
                          ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLight
                            ? scheme.outlineVariant.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categories.any((c) => c.id == _selectedCategoryId)
                            ? _selectedCategoryId
                            : (_categories.isNotEmpty ? _categories.first.id : null),
                        isExpanded: true,
                        dropdownColor: isLight ? Colors.white : const Color(0xFF1E1B38),
                        borderRadius: BorderRadius.circular(16),
                        items: _categories.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppStrings.getCategoryName(c.name),
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategoryId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Amount Field
                  Text(
                    AppStrings.allocatedLimitCurrency,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLight
                          ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: enteredAmount > 0
                            ? AppColors.primaryPurple
                            : (isLight
                                ? scheme.outlineVariant.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1)),
                        width: enteredAmount > 0 ? 1.5 : 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        hintText: '5,000',
                        hintStyle: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.3),
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Quick Increment Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _quickChip('+₹500', () => _addAmount(500), scheme, isLight),
                        _quickChip('+₹1,000', () => _addAmount(1000), scheme, isLight),
                        _quickChip('+₹2,000', () => _addAmount(2000), scheme, isLight),
                        _quickChip('+₹5,000', () => _addAmount(5000), scheme, isLight),
                        _quickChip('+₹10,000', () => _addAmount(10000), scheme, isLight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Daily Spending Allowance Projection Box
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primaryPurpleLight,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recommended Daily Pace',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryPurpleLight,
                                ),
                              ),
                              Text(
                                'Max ~₹$dailyAllowance / day across 30 days',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            AppStrings.cancel,
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveBudget,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppStrings.saveBudget,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _quickChip(
    String label,
    VoidCallback onTap,
    ColorScheme scheme,
    bool isLight,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLight
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLight
                  ? scheme.outlineVariant.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
