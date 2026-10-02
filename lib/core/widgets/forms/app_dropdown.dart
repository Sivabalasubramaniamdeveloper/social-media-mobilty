import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;
  final Widget? icon;

  const AppDropdownItem({required this.value, required this.label, this.icon});
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enabled;
  final IconData? prefixIcon;
  final double borderRadius;
  final bool isFilled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.prefixIcon,
    this.borderRadius = 16,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).secondaryHeaderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: AppColors.redColor, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        DropdownButtonFormField<T>(
          // value: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        item.icon!,
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          item.label,
                          style: TextStyle(color: secondaryColor, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          validator:
              validator ??
              (isRequired
                  ? (val) {
                      if (val == null) return AppStrings.fieldRequired;
                      return null;
                    }
                  : null),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
          ),
          dropdownColor: AppColors.darkBackgroundMid,
          style: TextStyle(color: secondaryColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint ?? AppStrings.selectOption,
            hintStyle: TextStyle(color: AppColors.hintText, fontSize: 15),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.secondaryText, size: 20)
                : null,
            filled: true,
            fillColor: isFilled
                ? AppColors.whiteColor
                : AppColors.whiteColor.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: isFilled
                  ? BorderSide.none
                  : BorderSide(color: AppColors.whiteColor.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.redColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: AppColors.redColor,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.redColor,
            ),
          ),
        ),
      ],
    );
  }
}
