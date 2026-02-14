import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double progress;
  final int percentage;

  const AppProgressBar({
    super.key,
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SYSTEM INITIALIZING",
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
