import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineai/config/firebase/local_notification.dart';
import 'package:mineai/config/flavor/flavor_config.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_actions/quick_actions.dart';
import 'app_providers.dart';
import 'config/router/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/network/internet_connectivity.dart';
import 'instance/locator.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final QuickActions _quickActions = const QuickActions();
  bool _firstCheckDone = false;

  final Map<String, String> _shortcutToRoute = {
    'quick_products': RouteNames.products,

    'quick_flowise': RouteNames.screen1,
  };
  @override
  void initState() {
    super.initState();
    setupLocator(context); // valid context

    // Register dynamic shortcuts (these show when long-pressing the app icon)
    _quickActions.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: 'quick_products',
        localizedTitle: 'Products',
        icon: 'ic_launcher', // platform icon name - see notes below
      ),
      ShortcutItem(
        type: 'quick_javis',
        localizedTitle: 'Javis',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'quick_flowise',
        localizedTitle: 'Flowise Chat',
        icon: 'ic_launcher',
      ),
    ]);

    // Initialize the callback to handle when a shortcut is tapped.
    // This will be called on cold start OR when the app is running.
    _quickActions.initialize((String shortcutType) {
      // shortcutType will be one of the 'type' values above
      _handleShortcut(shortcutType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getAppProviders(),
      child: ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        designSize: const Size(412, 846),
        builder: (context, child) {
          return MaterialApp.router(
            title: FlavorConfig.title,
            routerConfig: AppRouter.router,
            theme: AppTheme.getPrimaryTheme(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return BlocListener<ConnectivityCubit, ConnectivityStatus>(
                listener: (context, state) {
                  if (!_firstCheckDone &&
                      state != ConnectivityStatus.disconnected) {
                    _firstCheckDone = true; // skip first state
                    return;
                  }

                  if (state == ConnectivityStatus.disconnected) {
                    _firstCheckDone = true;
                    SnackBarHelper.networkError(
                      context,
                      "No Internet Connection",
                    );
                  } else {
                    SnackBarHelper.showSuccess(context, "Back Online");
                  }
                },
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  // Handle navigation centrally so we can ensure go_router is ready.
  Future<void> _handleShortcut(String shortcutType) async {
    if (shortcutType.isEmpty) return;

    final targetRoute = _shortcutToRoute[shortcutType];
    if (targetRoute == null) {
      // unknown shortcut: log or ignore
      debugPrint('Unknown quick action: $shortcutType');
      return;
    }

    // Ensure navigation happens after the current frame, and that the router is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // If you use named routes: AppRouter.router.goNamed('products');
        // Here we use path-based navigation:
        AppRouter.router.go(targetRoute);
      } catch (e) {
        debugPrint('Quick action navigation failed: $e');
      }
    });
  }
}
