import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mineai/core/constants/app_colors.dart';
import 'package:mineai/core/constants/app_sizes.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/widgets/logo/app_logo.dart';

/// Standard in-app top bar: back, title, optional trailing action.
class AppScreenHeader extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool centerTitle;
  final double titleSize;
  final Color? titleColor;

  const AppScreenHeader({
    super.key,
    this.title = '',
    this.titleWidget,
    this.onBack,
    this.trailing,
    this.centerTitle = false,
    this.titleSize = 18,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? AppColors.whiteColor;
    final back = IconButton(
      onPressed:
          onBack ??
          () {
            if (context.canPop()) context.pop();
          },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color,
        size: AppSizes.iconSm,
      ),
    );

    final titleText =
        titleWidget ??
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );

    if (centerTitle) {
      return Row(
        children: [
          if (onBack != null) back,
          Expanded(child: Center(child: titleText)),
          trailing ?? const SizedBox(width: 48),
        ],
      );
    }

    return Row(
      children: [
        back,
        const SizedBox(width: AppSizes.sm),
        Expanded(child: titleText),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Auth screens share this branded back row (logo + Mind AI).
class AppBrandHeader extends StatelessWidget {
  final VoidCallback onBack;
  final double logoSize;

  const AppBrandHeader({super.key, required this.onBack, this.logoSize = 100});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).secondaryHeaderColor;
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSizes.iconSm,
            color: color,
          ),
        ),
        const Spacer(),
        AppLogoWidget(size: logoSize, isWidth: true),
        const SizedBox(width: AppSizes.sm),
        Text(
          AppStrings.mindAi,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
