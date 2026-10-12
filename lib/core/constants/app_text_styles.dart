import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import '../../config/responsive/responsive_config.dart';
import '../../instance/locator.dart';

class AppTextStyles {
  ResponsiveConfig responsive = getIt<ResponsiveConfig>();
  late final TextStyle heading = TextStyle(
    fontSize: responsive.sp(17),
    fontWeight: FontWeight.bold,
  );

  late final TextStyle body = TextStyle(fontSize: responsive.sp(15));

  late final TextStyle caption = TextStyle(fontSize: responsive.sp(14));

  // Typographic presets for standardized typography across screens
  static const TextStyle display = TextStyle(
    fontSize: AppSizes.fontDisplay,
    fontWeight: FontWeight.w800,
    color: AppColors.whiteColor,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: AppSizes.fontHeaderLg,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteColor,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppSizes.fontSubheading,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteColor,
  );

  static const TextStyle cardHeader = TextStyle(
    fontSize: AppSizes.fontBody,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteColor,
  );

  static const TextStyle eyebrow = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.secondaryText,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: AppSizes.fontBodySm,
    fontWeight: FontWeight.w500,
    color: AppColors.accentLavender,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: AppSizes.fontBody,
    color: AppColors.whiteColor,
  );

  static const TextStyle secondaryBody = TextStyle(
    fontSize: AppSizes.fontBodySm,
    color: AppColors.secondaryText,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: AppSizes.fontCaption,
    color: AppColors.secondaryText,
  );

  static const TextStyle micro = TextStyle(
    fontSize: AppSizes.fontXs,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryText,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: AppSizes.fontAmount,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteColor,
  );
}
