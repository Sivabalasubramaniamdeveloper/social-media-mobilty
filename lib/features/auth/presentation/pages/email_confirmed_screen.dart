import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';

/// Confirms the Supabase email callback and directs the user to sign in.
class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  /// Shows the confirmation result and a route back to the login form.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 72,
                  color: scheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.emailConfirmedTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.emailConfirmedDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: Text(AppStrings.logIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
