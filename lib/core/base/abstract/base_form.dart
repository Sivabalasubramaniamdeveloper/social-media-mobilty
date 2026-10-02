import 'package:flutter/material.dart';
import 'package:mineai/core/base/abstract/base_screen.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/buttons/app_primary_button.dart';

/// Base form screen – extends [BaseScreen] with Form + validation.
///
/// Override:
/// - [formKey]
/// - [buildFormFields]
/// - [onSubmit]
/// - optionally [buildSubmitButton], [formPadding], [submitButtonTitle]
abstract class BaseFormScreen extends BaseScreen {
  const BaseFormScreen({super.key});

  /// Persistent form key – create once in State and pass via getter
  GlobalKey<FormState> get formKey;

  /// Form fields widgets
  List<Widget> buildFormFields(BuildContext context);

  /// Called when form is valid
  void onSubmit(BuildContext context);

  /// Submit button label
  String get submitButtonTitle => AppStrings.submit;

  /// Spacing between fields
  double get fieldSpacing => 18;

  /// Outer padding around the form
  EdgeInsets get formPadding => const EdgeInsets.all(16);

  /// Whether to show the default submit button
  bool get showSubmitButton => true;

  /// Custom submit button (override to replace default)
  Widget? buildSubmitButton(BuildContext context) => null;

  /// Extra widgets below the form fields (before submit)
  List<Widget> buildBelowFields(BuildContext context) => const [];

  /// Extra widgets above the form fields
  List<Widget> buildAboveFields(BuildContext context) => const [];

  @override
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: formPadding,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...buildAboveFields(context),
              ..._withSpacing(buildFormFields(context)),
              ...buildBelowFields(context),
              if (showSubmitButton) ...[
                SizedBox(height: fieldSpacing + 4),
                buildSubmitButton(context) ??
                    AppPrimaryButton(
                      title: submitButtonTitle,
                      onTap: () => _handleSubmit(context),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      onSubmit(context);
    }
  }

  List<Widget> _withSpacing(List<Widget> children) {
    if (children.isEmpty) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: fieldSpacing));
      }
    }
    return result;
  }
}
