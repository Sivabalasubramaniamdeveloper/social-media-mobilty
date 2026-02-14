import 'package:flutter/material.dart';

//	Centralized color definitions (Color(0xFF123456) or ColorName.primary).
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

  // Primary Accent
  static const Color primaryPurple = Color(0xFF7C5CFF);
  static const Color primaryOrange = Color.fromARGB(255, 243, 135, 3);

  // Secondary Accent
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentOrange = Color.fromARGB(255, 227, 190, 8);

  // Glass Card
  static const Color glassCard = Color(0x0DFFFFFF); // 5% white

  // Text Colors
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA0A3BD);
  static const Color hintText = Color(0xFF6C7293);

  // Error
  static const Color redColor = Color(0xFFE53935);
}
