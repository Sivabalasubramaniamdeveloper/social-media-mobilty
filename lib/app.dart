import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_automation/core/utils/snackbar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  @override
  void initState() {
    super.initState();
    setupLocator(context); // valid context
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
            title: "Flutter Automation",
            routerConfig: AppRouter.router,
            theme: AppTheme.getNaturalTheme(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return BlocListener<ConnectivityCubit, ConnectivityStatus>(
                listener: (context, state) {
                  if (state == ConnectivityStatus.disconnected) {
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
}
