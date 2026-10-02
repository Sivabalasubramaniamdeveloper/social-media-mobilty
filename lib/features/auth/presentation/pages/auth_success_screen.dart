import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';

class AuthSuccessScreen extends StatelessWidget {
  final String transactionId;
  final String timestamp;

  const AuthSuccessScreen({
    super.key,
    this.transactionId = '#MAI-8829-4X',
    this.timestamp = 'Oct 24, 2026 • 14:22',
  });

  @override
  Widget build(BuildContext context) {
    return _AuthSuccessView(transactionId: transactionId, timestamp: timestamp);
  }
}

class _AuthSuccessView extends BaseScreen {
  final String transactionId;
  final String timestamp;

  const _AuthSuccessView({
    required this.transactionId,
    required this.timestamp,
  });

  @override
  String get title => AppStrings.successTitle;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? width * 0.25 : 24),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),

            // Top Header: Logo + Close
            Row(
              children: [
                const AppLogoWidget(size: 80, isWidth: true),
                const SizedBox(width: 8),
                Text(
                  AppStrings.mindAi,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.go(RouteNames.home),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.whiteColor,
                    size: 22,
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // Checkmark Orb
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 54,
                color: AppColors.whiteColor,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              AppStrings.successTitle,
              style: TextStyle(
                fontSize: isTablet ? 34 : 30,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.successProcessedDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  height: 1.5,
                  color: AppColors.secondaryText,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Info Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.whiteColor.withOpacity(0.08),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.transactionId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        transactionId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.timestamp,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),

            // Bottom Action -> Back to Home Dashboard
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, Color(0xFF9059FF)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => context.go(RouteNames.dashboard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.backToHome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: AppColors.whiteColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // View Details link
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: AppColors.secondaryText,
              ),
              label: Text(
                AppStrings.viewTransactionDetails,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
