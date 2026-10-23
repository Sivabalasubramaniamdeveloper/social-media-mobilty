import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/utils/secure_storage.dart';
import 'package:mineai/core/widgets/app_progress_bar.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';
import 'package:mineai/instance/locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  int percentage = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (progress < 1.0) {
        setState(() {
          progress += 0.02;
          percentage = (progress * 100).clamp(0, 100).toInt();
        });
      } else {
        timer.cancel();
        navigateNext();
      }
    });
  }

  Future<void> navigateNext() async {
    if (!mounted) return;
    final secureStorage = getIt<CustomSecureStorage>();
    final token = await secureStorage.readSecureData('loginToken');

    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go(RouteNames.dashboard);
    } else {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogoWidget(size: 140, isWidth: true),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: AppProgressBar(
                  progress: progress,
                  percentage: percentage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
