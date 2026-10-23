import 'package:flutter/cupertino.dart';

class RouteFunctions {
  //  ----------------------
  //  NAVIGATION HELPERS
  // ----------------------
  // Navigate to a page by route name (no arguments)
  static navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  // Navigate to a page by route name with arguments
  static navigateToWithArgs(
    BuildContext context,
    String routeName,
    dynamic arguments,
  ) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Replace current page with a new one (no arguments)
  static replaceWith(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Replace current page with a new one with arguments
  static replaceWithArgs(
    BuildContext context,
    String routeName,
    dynamic arguments,
  ) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName,
    dynamic arguments,
  ) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  // Go back to previous page
  static goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }
}
