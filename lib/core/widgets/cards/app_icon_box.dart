import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';

/// Rounded square that holds a feature or list-row icon.
/// Adapts to light/dark themes automatically.
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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // Derive sensible defaults from the active theme when callers don't
    // supply explicit colours.
    final Color resolvedBg = backgroundColor ??
        (isLight
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : AppColors.iconSurface);

    final Color resolvedIcon = iconColor ??
        (isLight
            ? theme.colorScheme.primary
            : AppColors.accentLavender);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: resolvedIcon,
      ),
    );
  }
}
