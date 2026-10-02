// Shows snackbars or dialogs in a unified style.

import 'package:flutter/material.dart';

class SnackBarHelper {
  // Base function
  static void _show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black87,
    IconData? icon,
    Duration duration = const Duration(seconds: 1),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            if (icon != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Success
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  // Error
  static void showError(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.red, icon: Icons.error);
  }

  // Network Error
  static void networkError(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: Duration(days: 1),
    );
  }

  // Info
  static void showInfo(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.blue, icon: Icons.info);
  }

  // Warning
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }
}
