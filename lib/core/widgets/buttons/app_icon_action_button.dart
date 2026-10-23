import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/theme/app_decorations.dart';

/// Compact square icon button used in headers (notifications, refresh, etc.).
class AppIconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;

  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = AppSizes.iconBoxLg,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: AppDecorations.glass(
        context: context,
        radius: 14,
        fillOpacity: 0.7,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.onSurface,
          size: AppSizes.iconMd,
        ),
        onPressed: onTap,
      ),
    );
  }
}
