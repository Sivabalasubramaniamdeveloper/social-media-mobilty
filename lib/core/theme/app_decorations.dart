import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';

/// Shared decorations for glass cards, search fields, and list tiles.
class AppDecorations {
  AppDecorations._();

  static BoxDecoration glass({
    double radius = AppSizes.radiusMd,
    double fillOpacity = 0.55,
    double borderOpacity = 0.06,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? AppColors.surface).withValues(alpha: fillOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.whiteColor.withValues(alpha: borderOpacity),
      ),
    );
  }
}
