import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mineai/core/constants/app_strings.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: android,
      iOS: darwin,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification payload click action here
        debugPrint("Notification clicked: ${response.payload}");
      },
    );
    // Android 13+ requires an explicit runtime permission request. iOS requests
    // permissions through the Darwin implementation below.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<bool?> requestIOSPermissions() async {
    return await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      AppStrings.generalNotificationsChannel,
      channelDescription: AppStrings.generalNotificationsChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Present notification when app is in foreground
      presentBadge: true, // Update badge count
      presentSound: true, // Play default sound
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  Future<void> showBudgetWarning({
    required String categoryName,
    required int threshold,
    required double spent,
    required double limit,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'budget_alerts_channel',
      AppStrings.budgetAlertsChannel,
      channelDescription: AppStrings.budgetAlertsChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true, // Present notification when app is in foreground
      presentBadge: true, // Update badge count
      presentSound: true, // Play default sound
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final alertTitle = AppStrings.budgetAlertTitle(categoryName);
    final alertBody = threshold >= 100
        ? AppStrings.budgetAlertExceeded(
            spent.toStringAsFixed(2),
            limit.toStringAsFixed(2),
          )
        : AppStrings.budgetAlertUsed(threshold, categoryName);

    await _notifications.show(
      id: '${categoryName}_$threshold'.hashCode,
      title: alertTitle,
      body: alertBody,
      notificationDetails: details,
    );
  }
}
