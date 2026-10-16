import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/features/auth/cubit/auth_cubit.dart';
import 'package:mineai/features/auth/cubit/auth_state.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailConfirmationSent) {
          SnackBarHelper.showSuccess(context, AppStrings.verificationEmailSent);
        } else if (state is AuthFailure) {
          SnackBarHelper.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) => _VerifyEmailView(
        email: email,
        isLoading: state is AuthLoading,
        onResend: () =>
            context.read<AuthCubit>().resendSignupConfirmation(email),
      ),
    );
  }
}

class _VerifyEmailView extends BaseScreen {
  final String email;
  final bool isLoading;
  final VoidCallback onResend;

  const _VerifyEmailView({
    required this.email,
    required this.isLoading,
    required this.onResend,
  });

  @override
  String get title => AppStrings.verifyEmail;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  /// Shows the confirmation instructions, login action, and resend control.
  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    final secondaryTextColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? width * 0.25 : 24),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),

            // Top Header: Back Button + MindAI Brand
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.login);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const Spacer(),
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
                const Spacer(flex: 2),
              ],
            ),

            const Spacer(flex: 2),

            // Glowing Envelope Icon Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.3),
                    scheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 50,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              AppStrings.verifyYourEmail,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle with Masked / Passed Email
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: secondaryTextColor,
                ),
                children: [
                  TextSpan(text: '${AppStrings.weSentLinkTo}\n'),
                  TextSpan(
                    text: email,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              AppStrings.checkInboxDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: secondaryTextColor,
              ),
            ),

            const Spacer(flex: 3),

            // Primary Action: "I Have Verified" -> Navigates to Auth Success
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
                  onPressed: () => context.go(RouteNames.login),
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
                        AppStrings.iHaveVerified,
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

            const SizedBox(height: 14),

            // Secondary Action: Resend Email
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: isLoading ? null : onResend,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: scheme.onSurface.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: isLight
                      ? Colors.white
                      : AppColors.whiteColor.withValues(alpha: 0.04),
                ),
                child: isLoading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Text(
                        AppStrings.resendEmail,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Footer note
            Center(
              child: Text(
                AppStrings.checkSpamFolder,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ),

            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }
}
