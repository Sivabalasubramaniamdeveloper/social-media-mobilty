import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/features/auth/cubit/auth_cubit.dart';
import 'package:mineai/features/auth/cubit/auth_state.dart';

/// Lets a user choose a replacement password from a verified recovery session.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  /// Releases both password fields when the reset screen closes.
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  /// Validates the new password and submits it through Supabase Auth.
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().updatePassword(_passwordController.text);
    }
  }

  /// Displays password update feedback and returns successful users to login.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdated) {
          SnackBarHelper.showSuccess(context, AppStrings.passwordResetSuccess);
          context.go(RouteNames.login);
        } else if (state is AuthFailure) {
          SnackBarHelper.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(AppStrings.resetPassword)),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.password_rounded,
                      size: 64,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 24),
                    AppTextField.password(
                      controller: _passwordController,
                      label: AppStrings.newPassword,
                      style: AppTextFieldStyle.glass,
                    ),
                    const SizedBox(height: 16),
                    AppTextField.password(
                      controller: _confirmationController,
                      label: AppStrings.confirmNewPassword,
                      style: AppTextFieldStyle.glass,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        if (value != _passwordController.text) {
                          return AppStrings.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppStrings.resetPassword),
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
