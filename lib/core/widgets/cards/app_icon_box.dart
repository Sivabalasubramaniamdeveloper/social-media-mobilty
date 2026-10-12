import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';

/// Rounded square that holds a feature or list-row icon.
class AppIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double radius;

  const AppIconBox({
    super.key,
    required this.icon,
    this.size = AppSizes.iconBoxSm,
    this.iconSize = AppSizes.iconSm,
    this.backgroundColor,
    this.iconColor,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.iconSurface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? AppColors.accentLavender,
      ),
    );
  }
}
