import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles appTextStyles = getIt<AppTextStyles>();
ThemeData mindAITheme = ThemeData(
  brightness: Brightness.dark,
  secondaryHeaderColor: AppColors.whiteColor,
  primaryColor: AppColors.primaryPurple,
  scaffoldBackgroundColor: const Color.fromARGB(255, 3, 5, 17),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.whiteColor),
    titleTextStyle: TextStyle(
      color: AppColors.whiteColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryPurple,
    secondary: AppColors.accentBlue,
    surface: Color(0xFF141B3A),
    error: AppColors.redColor,
    onPrimary: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor,
    onSurface: AppColors.whiteColor,
    onError: AppColors.whiteColor,
  ),

  textTheme: TextTheme(
    bodyLarge: appTextStyles.body.copyWith(color: AppColors.whiteColor),
    bodyMedium: appTextStyles.caption.copyWith(color: AppColors.secondaryText),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 4,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryPurple,
    elevation: 6,
  ),

  cardTheme: CardThemeData(
    color: AppColors.glassCard,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);
