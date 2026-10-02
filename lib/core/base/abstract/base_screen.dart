import 'package:flutter/material.dart';
import 'package:mineai/core/widgets/gradiant_background.dart';

/// Abstract base screen with scaffold.
/// Override [showAppBar], [useGradientBackground], etc. as needed.
abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  String get title;

  /// Must be implemented
  Widget buildBody(BuildContext context);

  // Optional overrides
  List<Widget>? get actions => null;
  Widget? get floatingActionButton => null;
  Widget? get drawer => null;
  Color? get backgroundColor => null;
  Widget? get leading => null;
  bool get showAppBar => true;
  bool get centerTitle => true;
  bool get useGradientBackground => false;
  bool get resizeToAvoidBottomInset => true;

  @override
  Widget build(BuildContext context) {
    final body = buildBody(context);

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: centerTitle,
              actions: actions,
              leading: leading,
            )
          : null,
      body: useGradientBackground ? GradientBackground(child: body) : body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      backgroundColor: backgroundColor,
    );
  }
}
