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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_agreeTerms) {
      SnackBarHelper.showError(context, AppStrings.pleaseAgreeTerms);
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          SnackBarHelper.showSuccess(
            context,
            'Registration successful. Please log in.',
          );
          context.go(RouteNames.login);
        } else if (state is AuthFailure) {
          SnackBarHelper.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _SignUpFormView(
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmController: _confirmController,
          agreeTerms: _agreeTerms,
          isLoading: isLoading,
          onAgreeChanged: (val) => setState(() => _agreeTerms = val),
          onSubmitCallback: () => _onSubmit(context),
        );
      },
    );
  }
}

class _SignUpFormView extends BaseFormScreen {
  final GlobalKey<FormState> _key;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool agreeTerms;
  final bool isLoading;
  final ValueChanged<bool> onAgreeChanged;
  final VoidCallback onSubmitCallback;

  const _SignUpFormView({
    required GlobalKey<FormState> formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.agreeTerms,
    required this.isLoading,
    required this.onAgreeChanged,
    required this.onSubmitCallback,
  }) : _key = formKey;

  @override
  GlobalKey<FormState> get formKey => _key;

  @override
  String get title => AppStrings.createAccount;

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
            SizedBox(height: height * 0.04),
            Text(
              AppStrings.createAccount,
              style: TextStyle(
                fontSize: isTablet ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.joinFutureOfProductivity,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: height * 0.035),
            AppTextField(
              controller: nameController,
              label: AppStrings.fullName,
              hint: AppStrings.enterYourFullName,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              isRequired: true,
              style: AppTextFieldStyle.glass,
            ),
            SizedBox(height: height * 0.02),
            AppTextField.email(
              controller: emailController,
              style: AppTextFieldStyle.glass,
            ),
            SizedBox(height: height * 0.02),
            AppTextField.password(
              controller: passwordController,
              style: AppTextFieldStyle.glass,
            ),
            SizedBox(height: height * 0.02),
            AppTextField.password(
              controller: confirmController,
              label: AppStrings.confirm,
              style: AppTextFieldStyle.glass,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.fieldRequired;
                }
                if (value != passwordController.text) {
                  return AppStrings.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: agreeTerms,
                    onChanged: (val) => onAgreeChanged(val ?? false),
                    activeColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(
                      color: AppColors.secondaryText.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                      children: [
                        TextSpan(text: '${AppStrings.iAgreeToThe} '),
                        TextSpan(
                          text: AppStrings.termsOfService,
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
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
                  onPressed: (!agreeTerms || isLoading)
                      ? null
                      : onSubmitCallback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.createAccountButton,
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
            SizedBox(height: height * 0.035),
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
            SizedBox(height: height * 0.025),
            Row(
              children: [
                Expanded(
                  child: _socialBtn(
                    context,
                    AppStrings.google,
                    Icons.g_mobiledata_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _socialBtn(context, AppStrings.apple, Icons.apple),
                ),
              ],
            ),
            SizedBox(height: height * 0.04),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.login);
                      }
                    },
                    child: Text(
                      ' ${AppStrings.logIn}',
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

  Widget _socialBtn(BuildContext context, String label, IconData icon) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.secondaryText.withOpacity(0.25)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: AppColors.whiteColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).secondaryHeaderColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
