import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/theme/app_decorations.dart';
import 'package:mineai/core/widgets/cards/app_icon_box.dart';

/// Glass list row used for settings, recent activity, and similar tiles.
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppListTileCard(
      key: key,
      icon: icon,
      title: title,
      onTap: null,
      showChevron: false,
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: AppColors.primaryPurple,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: AppDecorations.glass(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: AppIconBox(icon: icon),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                )
              : null,
          trailing:
              trailing ??
              (showChevron
                  ? const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.secondaryText,
                    )
                  : null),
        ),
      ),
    );
  }
}
