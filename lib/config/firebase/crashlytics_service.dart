import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mineai/core/logger/app_logger.dart';

/// Centralized service to manage Firebase Crashlytics error reporting
/// across both Flutter UI errors and unhandled asynchronous platform errors.
class CrashlyticsService {
  static final CrashlyticsService instance = CrashlyticsService._();
  CrashlyticsService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Crashlytics hooks for fatal and non-fatal errors.
  Future<void> init() async {
    try {
      // Ensure Firebase default app is initialized before calling Crashlytics
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          debugPrint('Firebase.initializeApp() skipped or not configured: $e');
          return;
        }
      }

      final crashlytics = FirebaseCrashlytics.instance;

      // Automatically capture all errors that are thrown within the Flutter framework
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        crashlytics.recordFlutterFatalError(details);
      };

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable collection in release/profile builds or when explicitly desired
      await crashlytics.setCrashlyticsCollectionEnabled(true);

      _isInitialized = true;
      CustomAppLogger.info('Firebase Crashlytics initialized successfully', 'CrashlyticsService');
    } catch (e, stack) {
      debugPrint('Failed to initialize Firebase Crashlytics: $e');
      CustomAppLogger.error('Crashlytics initialization error: $e', 'CrashlyticsService', stack);
    }
  }

  /// Record a non-fatal caught exception with optional stack trace and context reason
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isInitialized) {
      debugPrint('[Crashlytics (mock/offline)] $reason: $exception');
      return;
    }
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('Crashlytics recordError failed: $e');
    }
  }

  /// Log a custom message to be included in the next crash report
  Future<void> log(String message) async {
    if (!_isInitialized) return;
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  /// Associate crashes with a specific authenticated user identifier
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (_) {}
  }

  /// Set key-value context metadata (e.g. active plan, active screen, current language)
  Future<void> setCustomKey(String key, Object value) async {
    if (!_isInitialized) return;
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }
}
