import 'package:flutter/material.dart';

/// Gradient / solid background wrapper used by BaseScreen.
/// In light themes it uses the scaffold background colour.
/// In dark / primary themes it uses the scaffold colour which is usually
/// an opaque dark surface — keeping the existing look.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child,
    );
  }
}
