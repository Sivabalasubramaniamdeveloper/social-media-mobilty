import 'package:flutter/material.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/network/alice.dart';
import 'package:mineai/features/expenses/models/transaction_model.dart';
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
import 'package:mineai/features/news/presentation/city_news_screen.dart';
import 'package:mineai/features/vault/presentation/vault_screen.dart';
import 'package:mineai/features/expenses/presentation/custom_categories_screen.dart';
import 'package:mineai/features/support/models/ticket_model.dart';
import 'package:mineai/features/support/presentation/create_ticket_screen.dart';
import 'package:mineai/features/support/presentation/support_tickets_screen.dart';
import 'package:mineai/features/support/presentation/ticket_detail_screen.dart';

class AppRouter {
  static CustomTransitionPage<void> _buildTransitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0.0),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  static GoRouter router = GoRouter(
    navigatorKey: dioProvider.navigatorKey,
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: '/',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, SplashScreen()),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const OnboardingScreen()),
      ),

      /// Login
      GoRoute(
        name: RouteNames.login,
        path: '/login',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const LoginScreen()),
      ),

      /// Sign Up
      GoRoute(
        name: RouteNames.signup,
        path: '/signup',
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const SignUpScreen()),
      ),

      GoRoute(
        name: RouteNames.verifyEmail,
        path: RouteNames.verifyEmail,
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          return _buildTransitionPage(state, VerifyEmailScreen(email: email));
        },
      ),
      GoRoute(
        path: RouteNames.emailConfirmed,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const EmailConfirmedScreen()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const ResetPasswordScreen()),
      ),
      GoRoute(
        name: RouteNames.dashboard,
        path: RouteNames.dashboard,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const HomeDashboardScreen()),
      ),
      GoRoute(
        name: RouteNames.editProfile,
        path: RouteNames.editProfile,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const EditProfileScreen()),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: RouteNames.settings,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const SettingsScreen()),
      ),
      GoRoute(
        name: RouteNames.weather,
        path: RouteNames.weather,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const WeatherScreen()),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: RouteNames.profile,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: RouteNames.addExpense,
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is TransactionModel) {
            return _buildTransitionPage(
              state,
              AddExpenseScreen(
                transactionToEdit: extra,
                initialType: extra.type,
              ),
            );
          }
          return _buildTransitionPage(
            state,
            AddExpenseScreen(initialType: extra as String? ?? 'expense'),
          );
        },
      ),
      GoRoute(
        path: RouteNames.incomeBudget,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const IncomeBudgetScreen()),
      ),
      GoRoute(
        path: RouteNames.subscription,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const SubscriptionScreen()),
      ),
      GoRoute(
        path: RouteNames.allTransactions,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const AllTransactionsScreen()),
      ),
      GoRoute(
        path: RouteNames.expenseSettings,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const ExpenseSettingsScreen()),
      ),
      GoRoute(
        name: RouteNames.comparePrices,
        path: RouteNames.comparePrices,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const PriceComparisonScreen()),
      ),
      GoRoute(
        name: RouteNames.ott,
        path: RouteNames.ott,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const OttHomeScreen()),
      ),
      GoRoute(
        name: RouteNames.apiKeys,
        path: RouteNames.apiKeys,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const ApiKeysScreen()),
      ),
      GoRoute(
        name: RouteNames.emailHelper,
        path: RouteNames.emailHelper,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const EmailHelperScreen()),
      ),
      GoRoute(
        name: RouteNames.voiceTasks,
        path: RouteNames.voiceTasks,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const AiVoiceAssistantScreen()),
      ),
      GoRoute(
        name: RouteNames.tasksList,
        path: RouteNames.tasksList,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const TasksListScreen()),
      ),
      GoRoute(
        name: RouteNames.news,
        path: RouteNames.news,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const CityNewsScreen()),
      ),
      GoRoute(
        name: RouteNames.vault,
        path: RouteNames.vault,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const VaultScreen()),
      ),
      GoRoute(
        name: RouteNames.customCategories,
        path: RouteNames.customCategories,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const CustomCategoriesScreen()),
      ),
      GoRoute(
        name: RouteNames.supportTickets,
        path: RouteNames.supportTickets,
        pageBuilder: (context, state) =>
            _buildTransitionPage(state, const SupportTicketsScreen()),
      ),
      GoRoute(
        name: RouteNames.createTicket,
        path: RouteNames.createTicket,
        pageBuilder: (context, state) => _buildTransitionPage(
          state,
          CreateTicketScreen(preselectedModule: state.extra as String?),
        ),
      ),
      GoRoute(
        name: RouteNames.ticketDetail,
        path: RouteNames.ticketDetail,
        pageBuilder: (context, state) => _buildTransitionPage(
          state,
          TicketDetailScreen(ticket: state.extra as TicketModel),
        ),
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
