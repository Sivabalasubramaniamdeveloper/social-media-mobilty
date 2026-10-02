import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/utils/validators_helper.dart';

enum AppTextFieldStyle { filled, outlined, glass }

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final AppTextFieldStyle style;
  final bool isRequired;
  final bool showPasswordToggle;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.inputFormatters,
    this.style = AppTextFieldStyle.glass,
    this.isRequired = false,
    this.showPasswordToggle = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.borderRadius = 16,
  });

  /// Email convenience constructor
  factory AppTextField.email({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    bool isRequired = true,
    AppTextFieldStyle style = AppTextFieldStyle.glass,
    void Function(String)? onChanged,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label ?? AppStrings.emailAddress,
      hint: hint ?? AppStrings.enterYourEmail,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      isRequired: isRequired,
      style: style,
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return AppStrings.fieldRequired;
        }
        if (value != null &&
            value.isNotEmpty &&
            !CommonRegExpression.validateEmailValidation(value.trim())) {
          return AppStrings.invalidEmail;
        }
        return null;
      },
    );
  }

  /// Password convenience constructor
  factory AppTextField.password({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    bool isRequired = true,
    bool showToggle = true,
    AppTextFieldStyle style = AppTextFieldStyle.glass,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      label: label ?? AppStrings.password,
      hint: hint ?? '••••••••',
      obscureText: true,
      showPasswordToggle: showToggle,
      prefixIcon: Icons.lock_outline_rounded,
      isRequired: isRequired,
      style: style,
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return AppStrings.fieldRequired;
            }
            if (value != null &&
                value.isNotEmpty &&
                !CommonRegExpression.validateAtLeastEightCharacter(value)) {
              return AppStrings.passwordTooShort;
            }
            return null;
          },
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).secondaryHeaderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(color: AppColors.redColor, fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          obscureText: _obscure,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          focusNode: widget.focusNode,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          validator:
              widget.validator ??
              (widget.isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      return null;
                    }
                  : null),
          style: TextStyle(color: secondaryColor, fontSize: 15),
          decoration: _buildDecoration(context),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final isGlass = widget.style == AppTextFieldStyle.glass;
    final isFilled = widget.style == AppTextFieldStyle.filled;

    Widget? suffix = widget.suffixIcon;
    if (widget.showPasswordToggle) {
      suffix = IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.secondaryText,
          size: 20,
        ),
      );
    }

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: TextStyle(color: AppColors.hintText, fontSize: 15),
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: AppColors.secondaryText, size: 20)
          : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: isFilled
          ? AppColors.whiteColor
          : isGlass
          ? AppColors.whiteColor.withOpacity(0.06)
          : Colors.transparent,
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: isFilled
            ? BorderSide.none
            : BorderSide(color: AppColors.whiteColor.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.primaryPurple,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(color: AppColors.redColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(color: AppColors.redColor, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.redColor),
    );
  }
}
