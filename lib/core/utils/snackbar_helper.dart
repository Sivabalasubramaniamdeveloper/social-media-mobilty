// Shows custom snackbars in a unified style across the whole app.

import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/network/alice.dart';

class SnackBarHelper {
  /// Strips technical debug traces, HTTP codes, and stack dumps into friendly user messages
  static String _sanitizeErrorMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return AppStrings.somethingWentWrong;
    }

    final lower = raw.toLowerCase();

    // 1. Connection / Network errors
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection timeout') ||
        lower.contains('connecttimeout') ||
        lower.contains('receivetimeout') ||
        lower.contains('no internet')) {
      return AppStrings.networkConnectionErrorMessage;
    }

    // 2. Server Errors (500, 502, 503, 504)
    if (lower.contains('500') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('internal server error') ||
        lower.contains('bad gateway') ||
        lower.contains('gateway timeout') ||
        lower.contains('server error')) {
      return AppStrings.serverErrorMessage;
    }

    // 3. AI / LLM service errors
    if (lower.contains('gemini') ||
        lower.contains('openai') ||
        lower.contains('anthropic') ||
        lower.contains('llm') ||
        lower.contains('quota exceeded') ||
        lower.contains('ai service') ||
        lower.contains('ai error') ||
        lower.contains('model is overloaded')) {
      return AppStrings.aiServiceErrorMessage;
    }

    // 4. Client / Bad Request errors (400, 422)
    if (lower.contains('400') ||
        lower.contains('422') ||
        lower.contains('bad request') ||
        lower.contains('unprocessable entity')) {
      return AppStrings.badRequestErrorMessage;
    }

    // 5. Auth / Permission errors (401, 403)
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return AppStrings.sessionExpiredMessage;
    }
    if (lower.contains('403') || lower.contains('forbidden')) {
      return AppStrings.accessDeniedMessage;
    }

    // 6. Rate limits (429)
    if (lower.contains('429') || lower.contains('too many requests')) {
      return AppStrings.rateLimitErrorMessage;
    }

    // 7. Strip out any "Exception:", "DioException:", "Error:" prefixes and technical traces
    String cleaned = raw
        .replaceAll(RegExp(r'^(Exception|DioException|Error):\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();

    // If it still contains raw code/stack traces or JSON/HTML dumps, return safe user message
    if (cleaned.contains('http') ||
        cleaned.contains('{') ||
        cleaned.contains('<') ||
        cleaned.length > 120 ||
        cleaned.contains('at ') ||
        cleaned.contains('line ')) {
      return AppStrings.somethingWentWrong;
    }

    return cleaned.isNotEmpty ? cleaned : AppStrings.somethingWentWrong;
  }

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
    final rawMsg = message ?? (context is String ? context as String : '');
    final msg = rawMsg.toLowerCase().contains('email') && rawMsg.toLowerCase().contains('sent')
        ? AppStrings.emailSentSuccess
        : rawMsg;
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
    final rawMsg = message ?? (context is String ? context as String : '');
    final msg = _sanitizeErrorMessage(rawMsg);
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
    final rawMsg = message ?? (context is String ? context as String : null);
    final msg = rawMsg ?? AppStrings.networkConnectionErrorMessage;
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
