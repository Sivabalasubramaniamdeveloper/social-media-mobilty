import 'package:flutter/widgets.dart';

typedef LifecycleCallback = void Function(AppLifecycleState state);

class AppLifecycleHandler with WidgetsBindingObserver {
  final LifecycleCallback onChange;

  AppLifecycleHandler({required this.onChange}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
