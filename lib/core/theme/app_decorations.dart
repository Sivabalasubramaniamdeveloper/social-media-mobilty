import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';

/// Shared decorations for glass cards, search fields, and list tiles.
class AppDecorations {
  AppDecorations._();

  /// Returns a glass-style decoration for dark themes, or a clean light
  /// card decoration for light themes.
  static BoxDecoration glass({
    double radius = AppSizes.radiusMd,
    double fillOpacity = 0.55,
    double borderOpacity = 0.06,
    Color? color,
    BuildContext? context,
  }) {
    // If a context is provided, use theme-awareness.
    if (context != null) {
      final theme = Theme.of(context);
      if (theme.brightness == Brightness.light) {
        return BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        );
      }
    }
    // Dark / default glass look
    return BoxDecoration(
      color: (color ?? AppColors.surface).withValues(alpha: fillOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.whiteColor.withValues(alpha: borderOpacity),
      ),
    );
  }
}
