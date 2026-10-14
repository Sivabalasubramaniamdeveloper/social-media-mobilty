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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    final secondaryTextColor =
        isLight ? AppColors.lightSecondaryOnSurface : AppColors.secondaryText;

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
                  icon: Icon(
                    Icons.close_rounded,
                    color: scheme.onSurface,
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
                color: scheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 54,
                color: scheme.onPrimary,
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
                  color: secondaryTextColor,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Info Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isLight
                    ? scheme.surfaceContainerHighest
                    : AppColors.whiteColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.transactionId,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                      Text(
                        transactionId,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
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
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
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
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: scheme.onPrimary,
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
              icon: Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: secondaryTextColor,
              ),
              label: Text(
                AppStrings.viewTransactionDetails,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
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
