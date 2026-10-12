import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';

/// Form card for entering a new income record.
class IncomeEntryCard extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedSource;
  final List<String> sourceOptions;
  final DateTime selectedDate;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSubmit;

  const IncomeEntryCard({
    super.key,
    required this.amountController,
    required this.noteController,
    required this.selectedSource,
    required this.sourceOptions,
    required this.selectedDate,
    required this.onSourceChanged,
    required this.onDateChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: AppSizes.fontHeaderLg,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: AppColors.incomeGreen,
                fontSize: AppSizes.fontHeaderLg,
                fontWeight: FontWeight.bold,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(color: AppColors.secondaryText),
              border: InputBorder.none,
            ),
          ),
          Divider(color: AppColors.whiteColor.withValues(alpha: 0.12)),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sourceOptions.contains(selectedSource)
                        ? selectedSource
                        : (sourceOptions.isNotEmpty ? sourceOptions.first : null),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: AppSizes.fontBodySm,
                    ),
                    items: sourceOptions
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(AppStrings.getCategoryName(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onSourceChanged(val);
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) onDateChanged(d);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: AppSizes.fontCaption,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: AppSizes.iconXs,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          TextField(
            controller: noteController,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: AppSizes.fontBodySm,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.incomeSourceDetails,
              hintStyle: const TextStyle(color: AppColors.secondaryText),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.fontBody,
                vertical: AppSizes.md,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeightSm,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.incomeGreenDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
                ),
              ),
              child: Text(
                AppStrings.addIncome,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: AppSizes.fontBodyLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
