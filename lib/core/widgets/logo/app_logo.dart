import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_colors.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor, blurRadius: 5),
        ],
      ),
      child: Icon(Icons.psychology, size: 45, color: AppColors.whiteColor),
    );
  }
}
