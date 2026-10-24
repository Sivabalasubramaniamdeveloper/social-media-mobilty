import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineai/core/widgets/headers/app_section_header.dart';
import 'package:mineai/core/widgets/cards/app_feature_card.dart';
import 'package:mineai/core/widgets/forms/app_search_field.dart';

void main() {
  group('Core Presentation Widgets Smoke Tests', () {
    testWidgets('AppSectionHeader renders title and action label',
        (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);

      await tester.tap(find.text('View All'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });

    testWidgets('AppFeatureCard renders title, description, and responds to tap',
        (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFeatureCard(
              title: 'Voice Tasks',
              description: 'AI task extraction',
              icon: Icons.mic_none_rounded,
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Voice Tasks'), findsOneWidget);
      expect(find.text('AI task extraction'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      await tester.tap(find.text('Voice Tasks'));
      await tester.pump();
      expect(cardTapped, isTrue);
    });

    testWidgets('AppSearchField accepts user input',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              controller: controller,
              hint: 'Search tools...',
            ),
          ),
        ),
      );

      expect(find.text('Search tools...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Weather');
      expect(controller.text, equals('Weather'));
    });
  });
}
