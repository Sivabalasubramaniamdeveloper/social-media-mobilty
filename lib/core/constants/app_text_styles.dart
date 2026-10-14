import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import '../../config/responsive/responsive_config.dart';
import '../../instance/locator.dart';

/// Typography presets.
///
/// The *instance* styles (heading / body / caption) carry no color so they
/// inherit from the active ThemeData.textTheme.
///
/// The *static* styles deliberately omit a color too — callers should use
///   AppTextStyles.display.copyWith(color: Theme.of(context).colorScheme.onSurface)
/// or rely on DefaultTextStyle inheritance so every theme works correctly.
class AppTextStyles {
  ResponsiveConfig responsive = getIt<ResponsiveConfig>();

  late final TextStyle heading = TextStyle(
    fontSize: responsive.sp(17),
    fontWeight: FontWeight.bold,
    // No color — inherited from theme
  );

  late final TextStyle body = TextStyle(fontSize: responsive.sp(15));

  late final TextStyle caption = TextStyle(fontSize: responsive.sp(14));

  // ── Typographic presets — NO hardcoded color ──────────────────────────
  // Callers must apply a color via .copyWith() or let the parent theme supply it.

  static const TextStyle display = TextStyle(
    fontSize: AppSizes.fontDisplay,
    fontWeight: FontWeight.w800,
    // color inherited from theme
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: AppSizes.fontHeaderLg,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppSizes.fontSubheading,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardHeader = TextStyle(
    fontSize: AppSizes.fontBody,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle eyebrow = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    // color: callers apply secondaryText or lightSecondaryOnSurface
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppSizes.fontBodySm,
    fontWeight: FontWeight.w500,
    // color: callers apply scheme.secondary
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: AppSizes.fontBody,
  );

  static const TextStyle secondaryBody = TextStyle(
    fontSize: AppSizes.fontBodySm,
    // color: callers apply secondaryText or lightSecondaryOnSurface
  );

  static const TextStyle captionText = TextStyle(
    fontSize: AppSizes.fontCaption,
  );

  static const TextStyle micro = TextStyle(
    fontSize: AppSizes.fontXs,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: AppSizes.fontAmount,
    fontWeight: FontWeight.bold,
  );
}
