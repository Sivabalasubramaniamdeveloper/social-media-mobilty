import 'package:flutter/material.dart';

class ResponsiveConfig {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;

  ResponsiveConfig(this.context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
  }

  // Width % of screen
  double wp(double percent) => screenWidth * percent / 100;

  // Height % of screen
  double hp(double percent) => screenHeight * percent / 100;

  // Font size scaling
  double sp(double size) {
    if (isPortrait) {
      return (screenWidth / 100) * (size / 3.75);
    } else {
      return (screenHeight / 100) * (size / 4.5);
    }
  }

  // Orientation checks
  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  // Tablet check (width ≥ 600px considered tablet)
  bool get isTablet => screenWidth >= 600;

  // -------- STATIC HELPERS -------- //

  // Static font scaling
  static double font(BuildContext context, double size) {
    final r = ResponsiveConfig(context);
    return r.sp(size);
  }

  // Get orientation directly
  static Orientation screenOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  // Responsive Sliver List/Grid
  static Widget responsiveListOrGrid({
    required BuildContext context,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
  }) {
    final r = ResponsiveConfig(context);

    if (r.isTablet || r.isLandscape) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns for tablet/landscape
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: r.isTablet ? 1.4 : 1.2,
        ),
        itemBuilder: itemBuilder,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }
  }

  // Responsive Form Fields (1 column for phone, 2+ for tablet/landscape)
  static Widget responsiveFormFields({
    required BuildContext context,
    required List<Widget> fields,
  }) {
    final r = ResponsiveConfig(context);

    if (r.isTablet || r.isLandscape) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: fields
            .map((f) => SizedBox(width: r.wp(45), child: f))
            .toList(),
      );
    } else {
      return Column(
        children: fields
            .map(
              (f) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: f),
            )
            .toList(),
      );
    }
  }
}
