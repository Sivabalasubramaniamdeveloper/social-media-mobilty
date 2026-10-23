import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles appTextStyles = getIt<AppTextStyles>();
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightPrimary,
    titleTextStyle: appTextStyles.heading.copyWith(color: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: appTextStyles.body,
    bodyMedium: appTextStyles.caption,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightPrimary,
    elevation: 2,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.lightSecondary,
    error: AppColors.error,
  ),
);
