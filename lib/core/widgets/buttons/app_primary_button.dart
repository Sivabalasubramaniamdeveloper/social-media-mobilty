import 'package:flutter/material.dart';

/// Full-width primary action button.
/// Background and foreground colours come from the active [ThemeData]
/// so the button adapts to every theme automatically.
class AppPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const AppPrimaryButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
