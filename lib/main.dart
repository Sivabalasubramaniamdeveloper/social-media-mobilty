import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mineai/config/env/env_config.dart';
import 'package:mineai/config/firebase/crashlytics_service.dart';
import 'package:mineai/config/firebase/notification_service.dart';
import 'package:mineai/config/firebase/push_notification.dart';
import 'package:mineai/firebase_options.dart';
import 'package:overlay_support/overlay_support.dart';
import 'app.dart';
import 'config/flavor/flavor_config.dart';
import 'config/supabase/supabase.config.dart';
import 'core/logger/app_logger.dart';
import 'core/network/alice.dart';
import 'core/widgets/errors/custom_error.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await NotificationService.instance.init();
      try {
        await CrashlyticsService.instance.init();
        await PushNotificationService.instance.init();
      } catch (e) {
        debugPrint('Firebase services non-fatal init error: $e');
      }
      await EasyLocalization.ensureInitialized();

      try {
        await EnvConfig.init();
      } catch (e) {
        throw Exception('Error loading .env file: $e');
      }

      await SupabaseConfig.initialize();
      await ScreenUtil.ensureScreenSize();
      await initializeDateFormatting();

      // Dynamic app icon switcher
      changeAppIcon();

      // 🚀 Render app as early as possible
      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('ta', ''), Locale('en', '')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: FlavorConfig.isDevelopment
              ? OverlaySupport.global(child: const MyApp())
              : const MyApp(),
        ),
      );

      // ✅ Non-critical tasks → run in background
      Future.microtask(() async {
        final alice = Alice(showNotification: FlavorConfig.isDevelopment);
        await dioProvider.initAlice(alice);

        ErrorWidget.builder = (FlutterErrorDetails details) {
          return MyCustomErrorWidget(details);
        };
      });
    },
    (error, stack) {
      CustomAppLogger.error(error.toString(), "runZonedGuarded");
      CrashlyticsService.instance.recordError(error, stack, fatal: true);
    },
  );
}

void changeAppIcon() async {
  const platform = MethodChannel('app.icon.change');

  try {
    final day = DateFormat('EEEE').format(DateTime.now());
    if (day == 'Saturday' || day == 'Sunday') {
      await platform.invokeMethod('setIcon', {'icon': 'weekend'});
    } else {
      await platform.invokeMethod('setIcon', {'icon': 'weekday'});
    }
  } catch (e) {
    // Platform channel will fail silently if native iOS/Android icons aren't configured yet
  }
}
