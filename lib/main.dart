import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_automation/core/logger/app_logger.dart';
import 'package:flutter_automation/core/widgets/custom_error.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';
import 'app.dart';
import 'config/flavor/flavor_config.dart';
import 'core/network/alice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      await EasyLocalization.ensureInitialized();

      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        throw Exception('Error loading .env file: $e');
      }

      await ScreenUtil.ensureScreenSize();

      // 🚀 Render app as early as possible
      runApp(
        EasyLocalization(
          supportedLocales: [Locale('ta', ''), Locale('en', '')],
          path: 'assets/translations',
          fallbackLocale: Locale('ta'),
          child: FlavorConfig.isDevelopment
              ? OverlaySupport.global(child: MyApp())
              : MyApp(),
        ),
      );

      // ✅ Non-critical tasks → run in background
      Future.microtask(() async {
        final alice = Alice(showNotification: FlavorConfig.isDevelopment);
        await dioProvider.initAlice(alice);

        ErrorWidget.builder = (FlutterErrorDetails details) {
          return MyCustomErrorWidget(details);
        };

        // Crashlytics setup can also be here
        // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        // PlatformDispatcher.instance.onError = (error, stack) {
        //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        //   return true;
        // };
      });
    },
    (error, stack) {
      CustomAppLogger.error(error.toString(), "runZonedGuarded");
    },
  );
}

void changeAppIcon() async {
  final now = DateTime.now();
  final day = DateFormat('EEEE').format(now); // Monday, Tuesday, etc.

  const platform = MethodChannel('app.icon.change');

  if (day == 'Saturday' || day == 'Sunday') {
    await platform.invokeMethod('setIcon', {'icon': 'weekend'});
  } else {
    await platform.invokeMethod('setIcon', {'icon': 'weekday'});
  }
}
