import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/core/widgets/headers/app_screen_header.dart';
import 'package:mineai/features/expenses/models/category_model.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
import 'package:mineai/features/expenses/presentation/widgets/widgets.dart';
import 'package:mineai/features/expenses/repositories/expense_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String _selectedCatId = '';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  List<CategoryModel> _expCategories = [];
  List<CategoryModel> _incCategories = [];
  bool _isSaving = false;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'guest_user';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final exp = await ExpenseDatabaseService.instance.getCategories(
      _userId,
      'expense',
    );
    final inc = await ExpenseDatabaseService.instance.getCategories(
      _userId,
      'income',
    );
    if (mounted) {
      setState(() {
        _expCategories = exp;
        _incCategories = inc;
        _selectedCatId = exp.isNotEmpty ? exp.first.id : '';
      });
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amt = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    if (amt == null || amt <= 0) return;

    setState(() => _isSaving = true);
    try {
      final activeList = _type == 'expense' ? _expCategories : _incCategories;
      final selectedCat = activeList.firstWhere(
        (c) => c.id == _selectedCatId,
        orElse: () => activeList.first,
      );

      final transaction = TransactionModel(
        userId: _userId,
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

      debugPrint('Saving transaction for user: $_userId with amount: $amt');
      await ExpenseRepositoryImpl().addTransaction(transaction, false);
      debugPrint('Transaction saved successfully');

      if (mounted) context.pop(true);
    } catch (e, stack) {
      debugPrint('Failed to save transaction: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
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
    final isExpense = _type == 'expense';
    final activeCategories = isExpense ? _expCategories : _incCategories;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.lg,
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
                const SizedBox(height: AppSizes.xl),
                TransactionTypeSwitch(
                  activeType: _type,
                  onTypeChanged: (type) {
                    setState(() {
                      _type = type;
                      final list = type == 'expense'
                          ? _expCategories
                          : _incCategories;
                      _selectedCatId = list.isNotEmpty ? list.first.id : '';
                    });
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                AmountInputField(
                  controller: _amountController,
                  accentColor: isExpense
                      ? AppColors.expenseRed
                      : AppColors.incomeGreen,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: AppSizes.lg + 2),
                AppTextField(
                  controller: _titleController,
                  label: AppStrings.titleLabel,
                  hint: isExpense
                      ? AppStrings.sampleExpenseTitle
                      : AppStrings.sampleIncomeTitle,
                  isRequired: false,
                  style: AppTextFieldStyle.glass,
                ),
                const SizedBox(height: AppSizes.lg + 2),
                CategoryDropdownField(
                  selectedCategoryId: _selectedCatId,
                  categories: activeCategories,
                  onCategoryChanged: (id) =>
                      setState(() => _selectedCatId = id),
                ),
                const SizedBox(height: AppSizes.lg + 2),
                _buildDateTimePicker(context),
                const SizedBox(height: AppSizes.lg + 2),
                AppTextField(
                  controller: _noteController,
                  label: '${AppStrings.remarks} (${AppStrings.optional})',
                  hint: AppStrings.additionalNotes,
                  maxLines: 3,
                  style: AppTextFieldStyle.glass,
                ),
                const SizedBox(height: AppSizes.xxxl),
                GradientActionButton(
                  text: isExpense
                      ? AppStrings.addNewExpense
                      : AppStrings.saveIncome,
                  gradientColors: isExpense
                      ? [AppColors.expenseRedDark, AppColors.expenseRedDeep]
                      : [
                          AppColors.incomeGreenDark,
                          AppColors.incomeGreenBorder,
                        ],
                  isLoading: _isSaving,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
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
              label: DateFormat('dd/MM/yyyy').format(_date),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: InkWell(
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _box({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.fontBody),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.fontTitleSm,
            color: AppColors.primaryPurple,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: AppSizes.fontBodySm,
            ),
          ),
        ],
      ),
    );
  }
}
