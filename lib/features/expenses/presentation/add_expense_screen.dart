import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/utils/user_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/widgets.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  final String initialType;

  const AddExpenseScreen({super.key, this.initialType = 'expense'});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _type = widget.initialType;
  String _selectedCatId = '';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  List<CategoryModel> _expCategories = [];
  List<CategoryModel> _incCategories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _currentUserId = 'guest_user';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final userId = await UserHelper.getCurrentUserId();
    if (!mounted) return;
    setState(() => _currentUserId = userId);
    await _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final exp = await ExpenseDatabaseService.instance.getCategories(
        _currentUserId,
        'expense',
      );
      final inc = await ExpenseDatabaseService.instance.getCategories(
        _currentUserId,
        'income',
      );
      if (mounted) {
        setState(() {
          _expCategories = exp;
          _incCategories = inc;
          if (_type == 'expense' && exp.isNotEmpty) {
            _selectedCatId = exp.first.id;
          } else if (_type == 'income' && inc.isNotEmpty) {
            _selectedCatId = inc.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuickAmount(double delta) {
    final current =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
        0.0;
    final total = current + delta;
    _amountController.text = total.toStringAsFixed(
      total.truncateToDouble() == total ? 0 : 2,
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amt = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.validAmountRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = await UserHelper.getCurrentUserId();
      final activeList = _type == 'expense' ? _expCategories : _incCategories;
      final selectedCat = activeList.firstWhere(
        (c) => c.id == _selectedCatId,
        orElse: () => activeList.isNotEmpty
            ? activeList.first
            : CategoryModel(id: 'other', name: 'Other', type: _type),
      );

      final transaction = TransactionModel(
        userId: userId,
        title: _titleController.text.trim().isEmpty
            ? selectedCat.name
            : _titleController.text.trim(),
        amount: amt,
        type: _type,
        categoryId: selectedCat.id,
        time: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
        updateTime: DateTime.now(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      debugPrint(
        'Saving transaction for user: $userId, amount: $amt, type: $_type',
      );
      await ExpenseRepositoryImpl().addTransaction(transaction, false);
      debugPrint('Transaction successfully logged!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _type == 'expense'
                  ? AppStrings.expenseSaved
                  : AppStrings.incomeSaved,
            ),
            backgroundColor: AppColors.statusSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop(true);
      }
    } catch (e, stack) {
      debugPrint('Failed to save transaction: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.failedToSave(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final isExpense = _type == 'expense';
    final activeCategories = isExpense ? _expCategories : _incCategories;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: scheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.md,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppScreenHeader(
                        title: isExpense
                            ? AppStrings.addNewExpense
                            : AppStrings.addIncome,
                        titleSize: AppSizes.fontHeading,
                        onBack: () => context.pop(),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Segmented Type Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : AppColors.surfaceDeep,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _type = 'expense';
                                    if (_expCategories.isNotEmpty) {
                                      _selectedCatId = _expCategories.first.id;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpense
                                        ? AppColors.expenseRedBg
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 18,
                                        color: isExpense
                                            ? Colors.white
                                            : (isLight
                                                  ? AppColors
                                                        .lightSecondaryOnSurface
                                                  : AppColors.secondaryText),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.expenses,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isExpense
                                              ? Colors.white
                                              : (isLight
                                                    ? AppColors
                                                          .lightSecondaryOnSurface
                                                    : AppColors.secondaryText),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _type = 'income';
                                    if (_incCategories.isNotEmpty) {
                                      _selectedCatId = _incCategories.first.id;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isExpense
                                        ? AppColors.incomeGreenBg
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 18,
                                        color: !isExpense
                                            ? Colors.white
                                            : (isLight
                                                  ? AppColors
                                                        .lightSecondaryOnSurface
                                                  : AppColors.secondaryText),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.income,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: !isExpense
                                              ? Colors.white
                                              : (isLight
                                                    ? AppColors
                                                          .lightSecondaryOnSurface
                                                    : AppColors.secondaryText),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.xl),

                      // Amount Input Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isLight
                              ? scheme.surfaceContainerHighest
                              : AppColors.surfaceDeep,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                (isExpense
                                        ? AppColors.expenseRed
                                        : AppColors.incomeGreen)
                                    .withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isExpense
                                          ? AppColors.expenseRed
                                          : AppColors.incomeGreen)
                                      .withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.amountLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: isExpense
                                    ? AppColors.expenseRed
                                    : AppColors.incomeGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: isExpense
                                        ? AppColors.expenseRed
                                        : AppColors.incomeGreen,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: AppStrings.sampleAmount,
                                      hintStyle: TextStyle(
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.3,
                                        ),
                                        fontSize: 34,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return AppStrings.fieldRequired;
                                      }
                                      final val = double.tryParse(
                                        v.trim().replaceAll(',', '.'),
                                      );
                                      if (val == null || val <= 0) {
                                        return 'Enter valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick Addition Pills
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _quickPill(
                                    '+\$10',
                                    () => _addQuickAmount(10),
                                    scheme,
                                  ),
                                  _quickPill(
                                    '+\$50',
                                    () => _addQuickAmount(50),
                                    scheme,
                                  ),
                                  _quickPill(
                                    '+\$100',
                                    () => _addQuickAmount(100),
                                    scheme,
                                  ),
                                  _quickPill(
                                    '+\$500',
                                    () => _addQuickAmount(500),
                                    scheme,
                                  ),
                                  _quickPill(
                                    '+\$1,000',
                                    () => _addQuickAmount(1000),
                                    scheme,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Title Field
                      AppTextField(
                        controller: _titleController,
                        label: AppStrings.titleLabel,
                        hint: isExpense
                            ? AppStrings.sampleExpenseTitle
                            : AppStrings.sampleIncomeTitle,
                        isRequired: false,
                        style: AppTextFieldStyle.glass,
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Category Dropdown
                      CategoryDropdownField(
                        selectedCategoryId: _selectedCatId,
                        categories: activeCategories,
                        onCategoryChanged: (id) =>
                            setState(() => _selectedCatId = id),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // Date & Time Picker
                      _buildDateTimePicker(context, scheme),

                      const SizedBox(height: AppSizes.md),

                      // Remarks
                      AppTextField(
                        controller: _noteController,
                        label: '${AppStrings.remarks} (${AppStrings.optional})',
                        hint: AppStrings.additionalNotes,
                        maxLines: 2,
                        style: AppTextFieldStyle.glass,
                      ),

                      const SizedBox(height: AppSizes.xxl),

                      // Save Button
                      GradientActionButton(
                        text: isExpense
                            ? AppStrings.addNewExpense
                            : AppStrings.saveIncome,
                        gradientColors: isExpense
                            ? [AppColors.expenseRed, AppColors.expenseRedDark]
                            : [
                                AppColors.incomeGreen,
                                AppColors.incomeGreenDark,
                              ],
                        isLoading: _isSaving,
                        onPressed: _onSave,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _quickPill(String label, VoidCallback onTap, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => _date = d);
            },
            child: _box(
              icon: Icons.calendar_today_rounded,
              label: DateFormat('MMM dd, yyyy').format(_date),
              scheme: scheme,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (t != null) setState(() => _time = t);
            },
            child: _box(
              icon: Icons.access_time_rounded,
              label: _time.format(context),
              scheme: scheme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _box({
    required IconData icon,
    required String label,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.fontTitleSm, color: scheme.secondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: AppSizes.fontBodySm,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
