import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/constants/app_text_styles.dart';
import 'package:mineai/core/logger/app_logger.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/responsive/responsive_config.dart';
import '../../../../core/widgets/bullet_points_text.dart';
import '../../../../instance/locator.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  ResponsiveConfig responsive = getIt<ResponsiveConfig>();
  AppTextStyles appTextStyles = getIt<AppTextStyles>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Automation Setup'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚀 Welcome to Flutter Automation App',
                style: appTextStyles.heading,
              ),
              Text(AppStrings.welcomeBack, style: appTextStyles.caption),
              Text(AppStrings.welcomeBack, style: appTextStyles.body),
              Text(AppStrings.username, style: appTextStyles.body),

              // Text(numbers[11].toString()),
              SizedBox(height: responsive.hp(2)),
              Text(
                '🔧 How to use:',
                style: TextStyle(
                  fontSize: responsive.sp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '- Open your terminal or Git Bash',
                style: appTextStyles.body,
              ),
              const Text('- Run the following command:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SelectableText(
                  './help.sh',
                  style: TextStyle(fontSize: 16, fontFamily: 'Courier'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '⚙️ Features Available:',
                style: appTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const BulletPoint(text: 'App name customization'),
              const BulletPoint(text: 'Bundle ID setup'),
              const BulletPoint(text: 'App icon configuration'),
              const BulletPoint(text: 'Flavor initialization'),
              const BulletPoint(text: 'Firebase integration via CLI'),
              const BulletPoint(text: 'Sample login page injection'),
              const SizedBox(height: 20),
              const Text(
                '✅ Use this automation tool to quickly set up your Flutter project with best practices!',
              ),
              ElevatedButton(
                onPressed: () {
                  // RouteFunctions.navigateToWithArgs(context, '/screen1', 123);
                  context.pushNamed('/screen1');
                },
                child: const Text('screen1'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed('/products');
                },
                child: const Text('products'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed('sss', pathParameters: {"id": "siva"});
                },
                child: const Text('products child'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed("/screen2");
                },
                child: const Text('screen2'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed("/screen3");
                },
                child: const Text('screen3'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.setLocale(Locale('ta', ''));
                  CustomAppLogger.appLogger(
                    "change language",
                    context.locale.toString(),
                  );
                },
                child: const Text('change language'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
