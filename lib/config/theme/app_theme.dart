import 'package:flutter/material.dart';
import 'package:mineai/config/theme/primary_theme.dart';
import 'light_theme.dart';
import 'dark_theme.dart';
import 'nature_theme.dart';
import 'orange_theme.dart';

class AppTheme {
  static ThemeData getLightTheme() => lightTheme;
  static ThemeData getDarkTheme() => darkTheme;
  static ThemeData getNaturalTheme() => natureTheme;
  static ThemeData getPrimaryTheme() => mindAITheme;
  static ThemeData getOrangeTheme() => mindAIOrangeTheme;
}
