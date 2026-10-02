import 'package:flutter/material.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/network/alice.dart';
import 'package:mineai/features/profile/presentation/edit_profile_screen.dart';
import 'package:mineai/features/profile/presentation/settings_screen.dart';
import 'package:mineai/features/splashscreen/presentation/splash_screen.dart';
import 'package:mineai/features/auth/presentation/pages/login_screen.dart';
import 'package:mineai/features/auth/presentation/pages/signup_screen.dart';
import 'package:mineai/features/onboard/presentation/onboarding_resume_ai_screen.dart';
import 'package:mineai/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:mineai/features/auth/presentation/pages/auth_success_screen.dart';
import 'package:mineai/features/home/presentation/home_dashboard_screen.dart';
import 'package:mineai/features/weather/presentation/weather_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    navigatorKey: dioProvider.navigatorKey,
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: '/',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      /// Login
      GoRoute(
        name: RouteNames.login,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// Sign Up
      GoRoute(
        name: RouteNames.signup,
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      GoRoute(
        name: RouteNames.verifyEmail,
        path: RouteNames.verifyEmail,
        builder: (context, state) {
          final email = state.extra as String? ?? 'user@email.com';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        name: RouteNames.authSuccess,
        path: RouteNames.authSuccess,
        builder: (context, state) => const AuthSuccessScreen(),
      ),
      GoRoute(
        name: RouteNames.dashboard,
        path: RouteNames.dashboard,
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        name: RouteNames.editProfile,
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: RouteNames.weather,
        path: RouteNames.weather,
        builder: (context, state) => const WeatherScreen(),
      ),
    ],
  );

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return _buildPageRoute(Container(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // From left
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
