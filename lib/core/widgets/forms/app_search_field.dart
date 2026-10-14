import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/theme/app_decorations.dart';

/// Glass search field used on the home dashboard and similar lists.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppSearchField({
    super.key,
    this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final secondaryText = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    return Container(
      height: AppSizes.searchHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: AppDecorations.glass(
        context: context,
        fillOpacity: 0.85,
        borderOpacity: 0.08,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: secondaryText,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: secondaryText, fontSize: 14),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
