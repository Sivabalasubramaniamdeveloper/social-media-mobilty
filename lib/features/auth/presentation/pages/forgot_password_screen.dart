import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/features/auth/cubit/auth_cubit.dart';
import 'package:mineai/features/auth/cubit/auth_state.dart';

/// Collects the account email and requests a Supabase recovery message.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// Releases the email field when the recovery screen is removed.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the address before asking Supabase to send the recovery link.
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().requestPasswordReset(_emailController.text);
    }
  }

  /// Shows a generic result that does not reveal whether an account exists.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetEmailSent) {
          SnackBarHelper.showSuccess(
            context,
            AppStrings.passwordResetEmailSent,
          );
        } else if (state is AuthFailure) {
          SnackBarHelper.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(AppStrings.forgotPasswordTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_reset, size: 64, color: scheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.forgotPasswordDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    AppTextField.email(
                      controller: _emailController,
                      style: AppTextFieldStyle.glass,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppStrings.sendResetLink),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: Text(AppStrings.logIn),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
