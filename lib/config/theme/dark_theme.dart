import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles appTextStyles = getIt<AppTextStyles>();

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkPrimary,
    titleTextStyle: appTextStyles.heading.copyWith(color: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: appTextStyles.body,
    bodyMedium: appTextStyles.caption,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    elevation: 2,
  ),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(secondary: AppColors.darkSecondary, error: AppColors.error),
);
