import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const AppGlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}
