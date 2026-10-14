import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/secure_storage.dart';
import '../../instance/locator.dart';
import 'app_theme.dart';

enum AppThemeMode {
  primary,
  // dark,
  // light,
  nature,
  // orange,
  whiteOrange,
  whiteBlue,
}

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.primary:
        return 'MindAI Purple (Dark)';
      // case AppThemeMode.dark:
      //   return 'Midnight Dark';
      // case AppThemeMode.light:
      //   return 'Clean Light';
      case AppThemeMode.nature:
        return 'Nature Green';
      // case AppThemeMode.orange:
      //   return 'Sunset Orange';
      case AppThemeMode.whiteOrange:
        return 'White & Orange';
      case AppThemeMode.whiteBlue:
        return 'White & Blue';
    }
  }

  Color get previewPrimaryColor {
    switch (this) {
      case AppThemeMode.primary:
        return const Color(0xFF6C5CE7);
      // case AppThemeMode.dark:
      //   return const Color(0xFF2D3436);
      // case AppThemeMode.light:
      //   return const Color(0xFF4A90E2);
      case AppThemeMode.nature:
        return const Color(0xFF2E7D32);
      // case AppThemeMode.orange:
      //   return const Color(0xFFFF7675);
      case AppThemeMode.whiteOrange:
        return const Color(0xFFFF6B00);
      case AppThemeMode.whiteBlue:
        return const Color(0xFF1976D2);
    }
  }

  Color get previewBackgroundColor {
    switch (this) {
      case AppThemeMode.primary:
        return const Color(0xFF0D0B1C);
      // case AppThemeMode.dark:
      //   return const Color(0xFF121212);
      // case AppThemeMode.light:
      //   return const Color(0xFFF8F9FA);
      case AppThemeMode.nature:
        return const Color(0xFFF4F1EE);
      // case AppThemeMode.orange:
      //   return const Color(0xFFFFF8F0);
      case AppThemeMode.whiteOrange:
        return const Color(0xFFFFFFFF);
      case AppThemeMode.whiteBlue:
        return const Color(0xFFFFFFFF);
    }
  }

  ThemeData get themeData {
    switch (this) {
      case AppThemeMode.primary:
        return AppTheme.getPrimaryTheme();
      // case AppThemeMode.dark:
      //   return AppTheme.getDarkTheme();
      // case AppThemeMode.light:
      //   return AppTheme.getLightTheme();
      case AppThemeMode.nature:
        return AppTheme.getNaturalTheme();
      // case AppThemeMode.orange:
      //   return AppTheme.getOrangeTheme();
      case AppThemeMode.whiteOrange:
        return AppTheme.getWhiteOrangeTheme();
      case AppThemeMode.whiteBlue:
        return AppTheme.getWhiteBlueTheme();
    }
  }
}

class ThemeState {
  final AppThemeMode mode;
  final ThemeData themeData;

  const ThemeState({required this.mode, required this.themeData});

  ThemeState copyWith({AppThemeMode? mode, ThemeData? themeData}) {
    return ThemeState(
      mode: mode ?? this.mode,
      themeData: themeData ?? this.themeData,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _storageKey = 'app_theme_mode';

  ThemeCubit()
    : super(
        ThemeState(
          mode: AppThemeMode.primary,
          themeData: AppTheme.getPrimaryTheme(),
        ),
      ) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final storage = getIt<CustomSecureStorage>();
      final savedModeName = await storage.readSecureData(_storageKey);
      if (savedModeName != null && savedModeName.isNotEmpty) {
        final matched = AppThemeMode.values.firstWhere(
          (m) => m.name == savedModeName,
          orElse: () => AppThemeMode.primary,
        );
        emit(ThemeState(mode: matched, themeData: matched.themeData));
      }
    } catch (e) {
      debugPrint('Error loading saved theme: $e');
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    emit(ThemeState(mode: mode, themeData: mode.themeData));
    try {
      final storage = getIt<CustomSecureStorage>();
      await storage.writeSecureData(_storageKey, mode.name);
      debugPrint('Saved default theme: ${mode.name}');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
