import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles appTextStyles = getIt<AppTextStyles>();
ThemeData natureTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.naturalBackground,
  scaffoldBackgroundColor: const Color(0xFFF4F1EE),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.naturalBackground,
    titleTextStyle: const TextStyle(
      color: AppColors.whiteColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(color: AppColors.whiteColor),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.naturalBackground,
    onPrimary: AppColors.whiteColor,
    secondary: AppColors.naturalSecondary,
    onSecondary: AppColors.whiteColor,
    error: AppColors.redColor,
    onError: AppColors.whiteColor,
    surface: AppColors.whiteColor,
    onSurface: AppColors.blackColor,
  ),
  textTheme: TextTheme(
    bodyLarge: appTextStyles.body,
    bodyMedium: appTextStyles.caption,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.naturalBackground,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.naturalBackground,
      foregroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
