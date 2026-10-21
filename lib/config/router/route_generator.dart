import 'package:flutter/material.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/network/alice.dart';
import 'package:mineai/features/expenses/presentation/add_expense_screen.dart';
import 'package:mineai/features/expenses/presentation/all_transactions_screen.dart';
import 'package:mineai/features/expenses/presentation/expense_settings_screen.dart';
import 'package:mineai/features/expenses/presentation/income_budget_screen.dart';
import 'package:mineai/features/profile/presentation/edit_profile_screen.dart';
import 'package:mineai/features/profile/presentation/profile_screen.dart';
import 'package:mineai/features/profile/presentation/settings_screen.dart';
import 'package:mineai/features/scraper/presentation/price_comparison_screen.dart';
import 'package:mineai/features/splashscreen/presentation/splash_screen.dart';
import 'package:mineai/features/subscription/presentation/subscription_screen.dart';
import 'package:mineai/features/auth/presentation/pages/login_screen.dart';
import 'package:mineai/features/auth/presentation/pages/signup_screen.dart';
import 'package:mineai/features/onboard/presentation/onboarding_resume_ai_screen.dart';
import 'package:mineai/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:mineai/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:mineai/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:mineai/features/auth/presentation/pages/email_confirmed_screen.dart';
import 'package:mineai/features/home/presentation/home_dashboard_screen.dart';
import 'package:mineai/features/weather/presentation/weather_screen.dart';
import 'package:mineai/features/ott/screens/ott_home_screen.dart';
import 'package:mineai/features/api_keys/presentation/api_keys_screen.dart';
import 'package:mineai/features/email_helper/presentation/email_helper_screen.dart';
import 'package:mineai/features/tasks/presentation/ai_voice_assistant_screen.dart';
import 'package:mineai/features/tasks/presentation/tasks_list_screen.dart';

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
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: RouteNames.emailConfirmed,
        builder: (context, state) => const EmailConfirmedScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
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
      GoRoute(
        name: RouteNames.profile,
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.addExpense,
        builder: (context, state) =>
            AddExpenseScreen(initialType: state.extra as String? ?? 'expense'),
      ),
      GoRoute(
        path: RouteNames.incomeBudget,
        builder: (context, state) => const IncomeBudgetScreen(),
      ),
      GoRoute(
        path: RouteNames.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: RouteNames.allTransactions,
        builder: (context, state) => const AllTransactionsScreen(),
      ),
      GoRoute(
        path: RouteNames.expenseSettings,
        builder: (context, state) => const ExpenseSettingsScreen(),
      ),
      GoRoute(
        name: RouteNames.comparePrices,
        path: RouteNames.comparePrices,
        builder: (context, state) => const PriceComparisonScreen(),
      ),
      GoRoute(
        name: RouteNames.ott,
        path: RouteNames.ott,
        builder: (context, state) => const OttHomeScreen(),
      ),
      GoRoute(
        name: RouteNames.apiKeys,
        path: RouteNames.apiKeys,
        builder: (context, state) => const ApiKeysScreen(),
      ),
      GoRoute(
        name: RouteNames.emailHelper,
        path: RouteNames.emailHelper,
        builder: (context, state) => const EmailHelperScreen(),
      ),
      GoRoute(
        name: RouteNames.voiceTasks,
        path: RouteNames.voiceTasks,
        builder: (context, state) => const AiVoiceAssistantScreen(),
      ),
      GoRoute(
        name: RouteNames.tasksList,
        path: RouteNames.tasksList,
        builder: (context, state) => const TasksListScreen(),
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
            body: Center(
              child: Text(AppStrings.routeNotFound(settings.name ?? '')),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
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
