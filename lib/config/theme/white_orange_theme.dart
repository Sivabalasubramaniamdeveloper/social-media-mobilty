import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../instance/locator.dart';

AppTextStyles _ts = getIt<AppTextStyles>();

/// White & Orange theme — light background, vivid orange accents.
/// Every widget that calls Theme.of(context).colorScheme / textTheme
/// will automatically adapt to this palette.
ThemeData whiteOrangeTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: false,

  // ── Scaffold ─────────────────────────────────────────────────────────
  scaffoldBackgroundColor: Colors.white,
  primaryColor: AppColors.woOrange,

  // secondaryHeaderColor is read by AppBrandHeader & misc widgets that
  // need to know the "on-surface" text colour for the current theme.
  secondaryHeaderColor: AppColors.lightOnSurface,

  // ── AppBar ────────────────────────────────────────────────────────────
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
    actionsIconTheme: const IconThemeData(color: AppColors.lightOnSurface),
    titleTextStyle: _ts.heading.copyWith(
      color: AppColors.lightOnSurface,
      fontWeight: FontWeight.bold,
    ),
    surfaceTintColor: Colors.transparent,
  ),

  // ── ColorScheme ───────────────────────────────────────────────────────
  colorScheme: const ColorScheme.light(
    primary: AppColors.woOrange,
    onPrimary: Colors.white,
    secondary: AppColors.woOrangeLight,
    onSecondary: Colors.white,
    surface: AppColors.woOrangeSurface,
    onSurface: AppColors.lightOnSurface,
    error: AppColors.redColor,
    onError: Colors.white,
    outline: AppColors.woOrange,
    // used by Dividers, borders etc.
    surfaceContainerHighest: AppColors.woCardBg,
  ),

  // ── Text Theme ────────────────────────────────────────────────────────
  textTheme: TextTheme(
    displayLarge: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 32),
    displayMedium: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 28),
    displaySmall: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 24),
    headlineLarge: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 22),
    headlineMedium: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 20),
    headlineSmall: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 18),
    titleLarge: _ts.heading.copyWith(color: AppColors.lightOnSurface, fontSize: 17),
    titleMedium: _ts.body.copyWith(color: AppColors.lightOnSurface, fontWeight: FontWeight.w600),
    titleSmall: _ts.caption.copyWith(color: AppColors.lightOnSurface, fontWeight: FontWeight.w600),
    bodyLarge: _ts.body.copyWith(color: AppColors.lightOnSurface),
    bodyMedium: _ts.caption.copyWith(color: AppColors.lightSecondaryOnSurface),
    bodySmall: _ts.caption.copyWith(color: AppColors.lightSecondaryOnSurface, fontSize: 12),
    labelLarge: _ts.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
    labelMedium: _ts.caption.copyWith(color: AppColors.lightOnSurface),
    labelSmall: _ts.caption.copyWith(color: AppColors.lightSecondaryOnSurface, fontSize: 11),
  ),

  // ── Card ──────────────────────────────────────────────────────────────
  cardTheme: CardThemeData(
    color: AppColors.woCardBg,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    shadowColor: AppColors.woOrange.withValues(alpha: 0.12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.woOrange.withValues(alpha: 0.15)),
    ),
  ),

  // ── Elevated Button ───────────────────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.woOrange,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.woOrangeLight.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      elevation: 2,
      shadowColor: AppColors.woOrange.withValues(alpha: 0.3),
    ),
  ),

  // ── Outlined Button ───────────────────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.woOrange,
      side: const BorderSide(color: AppColors.woOrange, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),

  // ── Text Button ───────────────────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.woOrange),
  ),

  // ── FAB ───────────────────────────────────────────────────────────────
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.woOrange,
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // ── Icon ─────────────────────────────────────────────────────────────
  iconTheme: const IconThemeData(color: AppColors.lightOnSurface),
  primaryIconTheme: const IconThemeData(color: Colors.white),

  // ── Input / TextField ─────────────────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.woOrangeSurface,
    hintStyle: const TextStyle(color: AppColors.lightSecondaryOnSurface),
    labelStyle: const TextStyle(color: AppColors.woOrange),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.woOrange.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.woOrange, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.redColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.redColor, width: 1.8),
    ),
  ),

  // ── Divider ───────────────────────────────────────────────────────────
  dividerTheme: DividerThemeData(
    color: AppColors.woOrange.withValues(alpha: 0.18),
    thickness: 1,
  ),

  // ── Switch (Cupertino-style color is set per widget via activeTrackColor) ──
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppColors.woOrange : Colors.white,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppColors.woOrange.withValues(alpha: 0.6)
          : Colors.grey.shade300,
    ),
  ),

  // ── Checkbox ─────────────────────────────────────────────────────────
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppColors.woOrange : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(Colors.white),
    side: const BorderSide(color: AppColors.woOrange),
  ),

  // ── BottomNavigationBar ──────────────────────────────────────────────
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.woOrange,
    unselectedItemColor: AppColors.lightSecondaryOnSurface,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),

  // ── NavigationBar (Material 3 style) ─────────────────────────────────
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.woOrangeSurface,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        color: s.contains(WidgetState.selected)
            ? AppColors.woOrange
            : AppColors.lightSecondaryOnSurface,
      ),
    ),
  ),

  // ── Slider ───────────────────────────────────────────────────────────
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.woOrange,
    thumbColor: AppColors.woOrange,
    overlayColor: AppColors.woOrange.withValues(alpha: 0.12),
    inactiveTrackColor: AppColors.woOrangeLight.withValues(alpha: 0.3),
  ),

  // ── Progress Indicator ────────────────────────────────────────────────
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.woOrange,
    circularTrackColor: AppColors.woOrangeSurface,
    linearTrackColor: AppColors.woOrangeSurface,
  ),

  // ── Chip ─────────────────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.woOrangeSurface,
    selectedColor: AppColors.woOrange,
    labelStyle: const TextStyle(color: AppColors.lightOnSurface),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.woOrange.withValues(alpha: 0.3)),
    ),
  ),

  // ── Dialog ───────────────────────────────────────────────────────────
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(
      color: AppColors.lightOnSurface,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: AppColors.lightSecondaryOnSurface),
  ),

  // ── BottomSheet ───────────────────────────────────────────────────────
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  // ── ListTile ─────────────────────────────────────────────────────────
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent,
    iconColor: AppColors.woOrange,
    textColor: AppColors.lightOnSurface,
  ),

  // ── TabBar ────────────────────────────────────────────────────────────
  tabBarTheme: const TabBarThemeData(
    labelColor: AppColors.woOrange,
    unselectedLabelColor: AppColors.lightSecondaryOnSurface,
    indicatorColor: AppColors.woOrange,
  ),
);
