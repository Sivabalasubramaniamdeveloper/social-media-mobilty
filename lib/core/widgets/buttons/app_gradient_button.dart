import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_sizes.dart';

/// Full-width gradient CTA used on expense/income save actions.
class AppGradientButton extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AppGradientButton({
    super.key,
    required this.text,
    required this.gradientColors,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          gradient: LinearGradient(colors: gradientColors),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Backward-compatible alias for existing expense screens.
typedef GradientActionButton = AppGradientButton;
