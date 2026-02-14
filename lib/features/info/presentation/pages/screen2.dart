import 'package:flutter/material.dart';
import 'package:mineai/core/utils/snackbar_helper.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/base/abstract/base_form.dart';

class Screen2 extends BaseFormScreen {
  Screen2({super.key});
  final _formKey = GlobalKey<FormState>();
  @override
  GlobalKey<FormState> get formKey => _formKey;

  @override
  String get title => "Login page";

  @override
  bool get showAppBar => true;

  @override
  List<Widget> buildFormFields(BuildContext context) {
    return [BasSss()];
  }

  @override
  void onSubmit(BuildContext context) {
    SnackBarHelper.showSuccess(context, "Login Successfully");
  }
}

class BasSss extends HookWidget {
  const BasSss({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    // Animation controller (1 second duration)
    final animationController = useAnimationController(
      duration: const Duration(seconds: 5),
    )..forward();

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    return Column(
      children: [
        FadeTransition(
          opacity: fadeAnimation,
          child: const Text(
            "Login Page",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
          validator: (val) => val!.isEmpty ? "Enter email" : null,
        ),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: "Password"),
          validator: (val) => val!.isEmpty ? "Enter Password" : null,
        ),
      ],
    );
  }
}
