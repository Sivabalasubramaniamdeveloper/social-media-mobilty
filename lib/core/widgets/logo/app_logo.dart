import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final bool isWidth;
  const AppLogoWidget({super.key, this.size = 100, this.isWidth = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isWidth ? size : size / 2,
      width: isWidth ? size / 2 : size,
      // ... rest same
      child: Icon(
        Icons.psychology,
        size: size * 0.45,
        color: AppColors.whiteColor,
      ),
    );
  }
}
