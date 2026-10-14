import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/theme/app_decorations.dart';
import 'package:mineai/core/widgets/cards/app_icon_box.dart';

/// Glass list row used for settings, recent activity, and similar tiles.
/// Uses Theme.of(context) so it adapts to all app themes automatically.
class AppListTileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const AppListTileCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  /// Settings row with a Cupertino switch on the right.
  factory AppListTileCard.toggle({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListTileCard(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: null,
      showChevron: false,
      trailing: _ThemedSwitch(value: value, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final titleColor = isLight
        ? AppColors.lightOnSurface
        : AppColors.whiteColor;
    final subtitleColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;
    final chevronColor = isLight
        ? AppColors.lightSecondaryOnSurface
        : AppColors.secondaryText;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: isLight
          ? BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            )
          : AppDecorations.glass(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: AppIconBox(icon: icon),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                )
              : null,
          trailing:
              trailing ??
              (showChevron
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: chevronColor,
                    )
                  : null),
        ),
      ),
    );
  }
}

/// Internal widget so the switch can access BuildContext for theming.
class _ThemedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ThemedSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CupertinoSwitch(
      value: value,
      activeTrackColor: primary,
      onChanged: onChanged,
    );
  }
}
