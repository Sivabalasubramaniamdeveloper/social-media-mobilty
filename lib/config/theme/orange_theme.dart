import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles appTextStyles = getIt<AppTextStyles>();
ThemeData mindAIOrangeTheme = ThemeData(
  brightness: Brightness.dark,
  secondaryHeaderColor: AppColors.blackColor,
  primaryColor: AppColors.primaryOrange,
  scaffoldBackgroundColor: AppColors.whiteColor,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.blackColor),
    titleTextStyle: TextStyle(
      color: AppColors.blackColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryOrange,
    secondary: AppColors.accentOrange,
    surface: Color(0xFF141B3A),
    error: AppColors.redColor,
    onPrimary: AppColors.blackColor,
    onSecondary: AppColors.blackColor,
    onSurface: AppColors.blackColor,
    onError: AppColors.blackColor,
  ),

  textTheme: TextTheme(
    bodyLarge: appTextStyles.body.copyWith(color: AppColors.blackColor),
    bodyMedium: appTextStyles.caption.copyWith(color: AppColors.secondaryText),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: AppColors.blackColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 4,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryOrange,
    elevation: 6,
  ),

  cardTheme: CardThemeData(
    color: AppColors.glassCard,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);
