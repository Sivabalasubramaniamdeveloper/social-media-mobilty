import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum LottieAnimationType {
  aiAnalyzing,
  emptyState,
  shoppingCart,
  walletFinance,
  successCheck,
  searchRocket,
}

/// Reusable and fail-safe Lottie / Animated graphic widget.
/// Provides rich motion graphics with animated fallback if offline.
class AppLottieView extends StatelessWidget {
  final LottieAnimationType type;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;

  const AppLottieView({
    super.key,
    required this.type,
    this.width = 160,
    this.height = 160,
    this.repeat = true,
    this.fit = BoxFit.contain,
  });

  String get _url {
    switch (type) {
      case LottieAnimationType.aiAnalyzing:
        return 'https://assets9.lottiefiles.com/packages/lf20_tno6cg2w.json';
      case LottieAnimationType.emptyState:
        return 'https://assets5.lottiefiles.com/packages/lf20_t24tpvcu.json';
      case LottieAnimationType.shoppingCart:
        return 'https://assets10.lottiefiles.com/packages/lf20_5ngs2ksb.json';
      case LottieAnimationType.walletFinance:
        return 'https://assets1.lottiefiles.com/packages/lf20_szviy45o.json';
      case LottieAnimationType.successCheck:
        return 'https://assets1.lottiefiles.com/packages/lf20_jbrw3hcz.json';
      case LottieAnimationType.searchRocket:
        return 'https://assets3.lottiefiles.com/packages/lf20_z9ed2jna.json';
    }
  }

  IconData get _fallbackIcon {
    switch (type) {
      case LottieAnimationType.aiAnalyzing:
        return Icons.auto_awesome_rounded;
      case LottieAnimationType.emptyState:
        return Icons.inbox_outlined;
      case LottieAnimationType.shoppingCart:
        return Icons.shopping_bag_outlined;
      case LottieAnimationType.walletFinance:
        return Icons.account_balance_wallet_rounded;
      case LottieAnimationType.successCheck:
        return Icons.check_circle_rounded;
      case LottieAnimationType.searchRocket:
        return Icons.rocket_launch_rounded;
    }
  }

  Color get _fallbackColor {
    switch (type) {
      case LottieAnimationType.aiAnalyzing:
        return const Color(0xFF6366F1);
      case LottieAnimationType.emptyState:
        return const Color(0xFF94A3B8);
      case LottieAnimationType.shoppingCart:
        return const Color(0xFF2874F0);
      case LottieAnimationType.walletFinance:
        return const Color(0xFF10B981);
      case LottieAnimationType.successCheck:
        return const Color(0xFF10B981);
      case LottieAnimationType.searchRocket:
        return const Color(0xFFEC4899);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.network(
        _url,
        fit: fit,
        repeat: repeat,
        errorBuilder: (context, error, stackTrace) => _buildAnimatedFallback(),
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return _buildAnimatedFallback();
          }
          return child;
        },
      ),
    );
  }

  Widget _buildAnimatedFallback() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.85, end: 1.15),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: (width ?? 120) * 0.7,
              height: (height ?? 120) * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _fallbackColor.withValues(alpha: 0.22),
                    _fallbackColor.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: Icon(
                _fallbackIcon,
                size: ((width ?? 120) * 0.4),
                color: _fallbackColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
