import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/widgets/app_progress_bar.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';

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
          progress += 0.01;
          percentage = (progress * 100).toInt();
        });
      } else {
        timer.cancel();
        navigateNext();
      }
    });
  }

  void navigateNext() {
    // Navigator.pushReplacementNamed(context, "/onboarding");
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final isTablet = width > 600;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// CENTER CONTENT
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? width * 0.25 : 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogoWidget(),
                        SizedBox(height: height * 0.04),

                        Text(
                          "MIND AI",
                          style: TextStyle(
                            fontSize: isTablet ? 42 : 34,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        Text(
                          "Your AI Productivity Hub",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            color:  Theme.of(context).secondaryHeaderColor,
                          ),
                        ),

                        SizedBox(height: height * 0.06),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? width * 0.1 : width * 0.15,
                          ),
                          child: AppProgressBar(
                            progress: progress,
                            percentage: percentage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// BOTTOM CONTENT
              Padding(
                padding: EdgeInsets.only(bottom: height * 0.04),
                child: Column(
                  children: const [
                    Text(
                      "⚡ POWERED BY ADVANCED LLMS",
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Version 2.4.0-pro",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
