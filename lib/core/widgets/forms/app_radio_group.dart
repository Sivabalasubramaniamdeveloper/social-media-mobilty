import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';

class AppRadioItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final Widget? leading;

  const AppRadioItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
  });
}

enum AppRadioLayout { vertical, horizontal, wrap }

class AppRadioGroup<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<AppRadioItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final AppRadioLayout layout;
  final bool enabled;
  final double spacing;

  const AppRadioGroup({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.layout = AppRadioLayout.vertical,
    this.enabled = true,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).secondaryHeaderColor;

    return FormField<T>(
      initialValue: value,
      validator:
          validator ??
          (isRequired
              ? (val) {
                  if (val == null) return AppStrings.fieldRequired;
                  return null;
                }
              : null),
      builder: (field) {
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
              const SizedBox(height: 12),
            ],
            _buildOptions(context, field),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style: const TextStyle(fontSize: 12, color: AppColors.redColor),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOptions(BuildContext context, FormFieldState<T> field) {
    final children = items.map((item) {
      final selected = field.value == item.value;
      return _RadioTile<T>(
        item: item,
        selected: selected,
        enabled: enabled,
        onTap: enabled
            ? () {
                field.didChange(item.value);
                onChanged(item.value);
              }
            : null,
      );
    }).toList();

    switch (layout) {
      case AppRadioLayout.horizontal:
        return Row(
          children: children
              .map(
                (w) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: w,
                  ),
                ),
              )
              .toList(),
        );
      case AppRadioLayout.wrap:
        return Wrap(spacing: spacing, runSpacing: spacing, children: children);
      case AppRadioLayout.vertical:
        return Column(
          children: children
              .map(
                (w) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: w,
                ),
              )
              .toList(),
        );
    }
  }
}

class _RadioTile<T> extends StatelessWidget {
  final AppRadioItem<T> item;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _RadioTile({
    required this.item,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).secondaryHeaderColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple.withOpacity(0.12)
              : AppColors.whiteColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : AppColors.whiteColor.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (item.leading != null) ...[
              item.leading!,
              const SizedBox(width: 12),
            ],
            // Custom radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.secondaryText,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
