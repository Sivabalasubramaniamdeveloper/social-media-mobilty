import 'package:flutter/material.dart';

/// Centralized palette. Screens should use these instead of inline hex values.
class AppColors {
  // Common Colors

  static const Color blackColor = Colors.black;
  static const Color black87Color = Colors.black87;
  static const Color black54Color = Colors.black54;
  static const Color greenColor = Colors.green;
  static const Color error = Color(0xFFB00020);
  // Light Colors
  static const Color lightBackground = Colors.white;
  static const Color lightText = Colors.black;
  static const Color lightPrimary = Color(0xFF6200EE);
  static const Color lightSecondary = Color(0xFF03DAC6);

  // Dark Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Colors.white;
  static const Color darkPrimary = Color(0xFF6200EE);
  static const Color darkSecondary = Color(0xFF03DAC6);

  // Natural Colors
  static final Color naturalBackground = Colors.green[700]!;
  static const Color naturalText = Colors.white;
  static final Color naturalSecondary = Colors.brown[400]!;

  //primarytheme
  static const Color primaryThemeBackground = Color(0xFF0B0F2A);
  static const Color darkBackgroundTop = Color(0xFF0B0F2A);
  static const Color darkBackgroundMid = Color(0xFF141B3A);
  static const Color darkBackgroundBottom = Color(0xFF1C1147);
  static const Color scaffoldBackground = Color(0xFF0F0C20);

  // Primary Accent
  static const Color primaryPurple = Color(0xFF7C5CFF);
  static const Color primaryPurpleDark = Color(0xFF6366F1);
  static const Color primaryPurpleLight = Color(0xFF8B5CF6);
  static const Color primaryPurpleDeep = Color(0xFF7C3AED);
  static const Color primaryOrange = Color.fromARGB(255, 243, 135, 3);

  // Secondary Accent
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentOrange = Color.fromARGB(255, 227, 190, 8);
  static const Color accentLavender = Color(0xFFA78BFA);

  // Surfaces used by glass cards and list tiles
  static const Color surface = Color(0xFF1E1B38);
  static const Color surfaceDeep = Color(0xFF161426);
  static const Color surfaceElevated = Color(0xFF1D1533);
  static const Color surfaceGreenTint = Color(0xFF142426);
  static const Color iconSurface = Color(0xFF2E2752);

  // Income / Positive Colors
  static const Color incomeGreen = Color(0xFF34D399);
  static const Color incomeGreenBg = Color(0xFF064E3B);
  static const Color incomeGreenDark = Color(0xFF059669);
  static const Color incomeGreenBorder = Color(0xFF059669);

  // Expense / Negative Colors
  static const Color expenseRed = Color(0xFFF87171);
  static const Color expenseRedBg = Color(0xFF7F1D1D);
  static const Color expenseRedDark = Color(0xFFDC2626);
  static const Color expenseRedDeep = Color(0xFF991B1B);
  static const Color expenseOrange = Color(0xFFF97316);
  static const Color expenseOrangeBg = Color(0xFF38231E);

  // Status Colors
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusSuccess = Color(0xFF34D399);

  // Glass Card
  static const Color glassCard = Color(0x0DFFFFFF); // 5% white
  static const Color cardBorder = Color(0x0FFFFFFF); // ~6% white

  // Text Colors
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA0A3BD);
  static const Color hintText = Color(0xFF6C7293);

  // Error
  static const Color redColor = Color(0xFFE53935);
}
