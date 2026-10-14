import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/database/app_database.dart';

/// Modal dialog for setting or updating a monthly savings goal.
class SavingsGoalDialog extends StatefulWidget {
  final String userId;
  final String monthYear;
  final double? currentGoal;
  final VoidCallback onSaved;

  const SavingsGoalDialog({
    super.key,
    required this.userId,
    required this.monthYear,
    this.currentGoal,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String monthYear,
    double? currentGoal,
    required VoidCallback onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SavingsGoalDialog(
        userId: userId,
        monthYear: monthYear,
        currentGoal: currentGoal,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<SavingsGoalDialog> createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentGoal != null && widget.currentGoal! > 0
          ? widget.currentGoal!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (target != null && target > 0) {
      await ExpenseDatabaseService.instance.setSavingsGoal(
        widget.userId,
        widget.monthYear,
        target,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.enterValidAmount),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final secondaryText = isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText;

    final isEditing = widget.currentGoal != null && widget.currentGoal! > 0;

    return AlertDialog(
      backgroundColor: isLight ? Colors.white : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        isEditing ? AppStrings.editSavingsGoal : AppStrings.addSavingsGoal,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: AppSizes.fontTitleSm,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.targetAmount} (${AppStrings.optional})',
            style: TextStyle(
              color: secondaryText,
              fontSize: AppSizes.fontBodySm,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: AppSizes.fontTitleSm,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: AppColors.incomeGreen,
                fontSize: AppSizes.fontTitleSm,
                fontWeight: FontWeight.bold,
              ),
              hintText: AppStrings.sampleSavingsGoal,
              hintStyle: TextStyle(color: secondaryText),
              filled: true,
              fillColor: isLight
                  ? scheme.surfaceContainerHighest
                  : Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: BorderSide.none,
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
            style: TextStyle(color: secondaryText),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),
          onPressed: _submit,
          child: Text(
            AppStrings.submit,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
