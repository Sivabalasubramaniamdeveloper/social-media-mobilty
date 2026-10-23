// Shows custom snackbars in a unified style across the whole app.

import 'package:flutter/material.dart';
import 'package:mineai/core/network/alice.dart';

class SnackBarHelper {
  // Base function
  static void _show(
    BuildContext? context,
    String message, {
    Color backgroundColor = Colors.black87,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = context ?? dioProvider.navigatorKey?.currentContext;
    if (ctx == null) return;

    try {
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger == null) return;

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          content: Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 20),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {}
  }

  // Success
  static void showSuccess([BuildContext? context, String? message]) {
    final msg = message ?? (context is String ? context as String : '');
    final ctx = context is BuildContext ? context : null;
    _show(
      ctx,
      msg,
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  // Error
  static void showError([BuildContext? context, String? message]) {
    final msg = message ?? (context is String ? context as String : '');
    final ctx = context is BuildContext ? context : null;
    _show(
      ctx,
      msg,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error_outline_rounded,
    );
  }

  // Network Error
  static void networkError([BuildContext? context, String? message]) {
    final msg = message ?? (context is String ? context as String : 'No internet connection');
    final ctx = context is BuildContext ? context : null;
    _show(
      ctx,
      msg,
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.wifi_off_rounded,
      duration: const Duration(seconds: 5),
    );
  }

  // Info
  static void showInfo([BuildContext? context, String? message]) {
    final msg = message ?? (context is String ? context as String : '');
    final ctx = context is BuildContext ? context : null;
    _show(
      ctx,
      msg,
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info_outline_rounded,
    );
  }

  // Warning
  static void showWarning([BuildContext? context, String? message]) {
    final msg = message ?? (context is String ? context as String : '');
    final ctx = context is BuildContext ? context : null;
    _show(
      ctx,
      msg,
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
    );
  }
}
