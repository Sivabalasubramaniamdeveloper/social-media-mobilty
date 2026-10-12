import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Present notification when app is in foreground
      presentBadge: true, // Update badge count
      presentSound: true, // Play default sound
    );

    const NotificationDetails platformDetails = NotificationDetails(
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
    required double percentage,
    required double spent,
    required double limit,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts_channel',
      'Budget Alerts',
      channelDescription: 'Notifications for exceeding budget limits',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true, // Present notification when app is in foreground
      presentBadge: true, // Update badge count
      presentSound: true, // Play default sound
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    String alertTitle = 'Budget Alert: $categoryName';
    String alertBody = '';

    if (percentage >= 100) {
      alertBody =
          'Budget Exceeded! Spent \$${spent.toStringAsFixed(2)} of \$${limit.toStringAsFixed(2)} limit.';
    } else if (percentage >= 90) {
      alertBody =
          'Critical: Used ${percentage.toStringAsFixed(0)}% of your $categoryName budget.';
    } else if (percentage >= 50) {
      alertBody = 'Notice: Reached 50% of your $categoryName budget limit.';
    }

    await _notifications.show(
      id: categoryName.hashCode,
      title: alertTitle,
      body: alertBody,
      notificationDetails: details,
    );
  }
}
