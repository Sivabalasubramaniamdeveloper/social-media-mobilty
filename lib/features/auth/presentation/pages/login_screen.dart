import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/config/router/route_names.dart';
import 'package:mineai/core/base/abstract/base_form.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:mineai/core/widgets/forms/app_text_field.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';
import 'package:mineai/features/auth/cubit/auth_cubit.dart';
import 'package:mineai/features/auth/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          context.go(RouteNames.dashboard);
        } else if (state is AuthFailure) {
          SnackBarHelper.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _LoginFormView(
          formKey: _formKey,
          emailController: _emailController,
          passwordController: _passwordController,
          isLoading: isLoading,
          onSubmitCallback: () => _onSubmit(context),
        );
      },
    );
  }
}

class _LoginFormView extends BaseFormScreen {
  final GlobalKey<FormState> _key;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmitCallback;

  const _LoginFormView({
    required GlobalKey<FormState> formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmitCallback,
  }) : _key = formKey;

  @override
  GlobalKey<FormState> get formKey => _key;

  @override
  String get title => AppStrings.logIn;

  @override
  bool get showAppBar => false;

  @override
  bool get useGradientBackground => true;

  @override
  EdgeInsets get formPadding => EdgeInsets.zero;

  @override
  bool get showSubmitButton => false;

  @override
  void onSubmit(BuildContext context) => onSubmitCallback();

  @override
  List<Widget> buildFormFields(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isTablet = width > 600;

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? width * 0.25 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.onboarding);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const Spacer(),
                const AppLogoWidget(size: 100, isWidth: true),
                const SizedBox(width: 8),
                Text(
                  AppStrings.mindAi,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            SizedBox(height: height * 0.05),
            Text(
              AppStrings.welcomeBack,
              style: TextStyle(
                fontSize: isTablet ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.loginToContinue,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: height * 0.04),
            AppTextField.email(
              controller: emailController,
              style: AppTextFieldStyle.glass,
            ),
            SizedBox(height: height * 0.025),
            AppTextField.password(
              controller: passwordController,
              style: AppTextFieldStyle.glass,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.forgotPassword,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.035),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.accentBlue],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmitCallback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          AppStrings.logIn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: height * 0.04),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.secondaryText.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.or,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.secondaryText.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.secondaryText.withOpacity(0.25),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: AppColors.whiteColor.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.continueWithGoogle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontHaveAccount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.signup),
                    child: Text(
                      ' ${AppStrings.signUp}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.04),
          ],
        ),
      ),
    ];
  }
}
