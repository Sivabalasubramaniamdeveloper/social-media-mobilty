import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/base/abstract/base_form.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/database/app_database.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import '../models/expense_model.dart';

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

  String _selectedCategory = 'Food & Drinks';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  final List<String> _categories = [
    'Food & Drinks',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Health',
    'Utilities',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryPurple,
            surface: Color(0xFF1E1B38),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryPurple,
            surface: Color(0xFF1E1B38),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _onSave() async {
    // 1. Form Validation Check
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. Parse Amount safely
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final double? parsedAmount = double.tryParse(rawAmount);

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Set loading state
    setState(() => _isSaving = true);

    try {
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final expense = ExpenseModel(
        title: _titleController.text.trim(),
        amount: parsedAmount,
        category: _selectedCategory,
        time: finalDateTime,
        updateTime: DateTime.now(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // SQLite Insert
      await AppDatabase.instance.insertExpense(expense);

      if (mounted) {
        context.pop(true); // Return back to previous screen
      }
    } catch (error) {
      debugPrint('Error inserting expense: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // ALWAYS reset loading even if DB fails or navigation didn't dismiss
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AddExpenseView(
      formKey: _formKey,
      titleController: _titleController,
      amountController: _amountController,
      noteController: _noteController,
      selectedCategory: _selectedCategory,
      categories: _categories,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      isSaving: _isSaving,
      onCategoryChanged: (val) => setState(() => _selectedCategory = val),
      onPickDate: _pickDate,
      onPickTime: _pickTime,
      onSave: _onSave,
    );
  }
}

class _AddExpenseView extends BaseFormScreen {
  final GlobalKey<FormState> _key;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategory;
  final List<String> categories;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool isSaving;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onSave;

  const _AddExpenseView({
    required GlobalKey<FormState> formKey,
    required this.titleController,
    required this.amountController,
    required this.noteController,
    required this.selectedCategory,
    required this.categories,
    required this.selectedDate,
    required this.selectedTime,
    required this.isSaving,
    required this.onCategoryChanged,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSave,
  }) : _key = formKey;

  @override
  GlobalKey<FormState> get formKey => _key;

  @override
  String get title => 'Add Expense';

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  EdgeInsets get formPadding => EdgeInsets.zero;

  @override
  bool get showSubmitButton => false;

  @override
  void onSubmit(BuildContext context) => onSave();

  @override
  List<Widget> buildFormFields(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? size.width * 0.25 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header Bar
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Add New Expense',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Input Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161426),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '\$ ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppColors.secondaryText),
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter amount'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Title
            AppTextField(
              controller: titleController,
              label: 'Expense Title',
              hint: 'e.g. Starbucks, Grocery, Train ticket',
              isRequired: true,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 18),

            // Category Picker
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B38).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.08),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E1B38),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryText,
                  ),
                  onChanged: (val) {
                    if (val != null) onCategoryChanged(val);
                  },
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Date & Time Selectors
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onPickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B38).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.whiteColor.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onPickTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B38).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.whiteColor.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime.format(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Note / Description
            AppTextField(
              controller: noteController,
              label: 'Notes (Optional)',
              hint: 'Add extra details...',
              maxLines: 3,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.accentBlue],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ];
  }
}
