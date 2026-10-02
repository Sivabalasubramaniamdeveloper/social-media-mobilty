import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ============================================================
/// FIREBASE BACKGROUND MESSAGE HANDLER
/// ============================================================
///
/// This function must be a top-level function.
/// It is called when Firebase receives a notification while the
/// application is in the background/terminated state.
///
/// Keep this function outside the PushNotificationService class.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need Firebase services inside this handler,
  // initialize Firebase here.
  //
  // await Firebase.initializeApp();

  debugPrint('Background message received: ${message.messageId}');
}

/// ============================================================
/// PUSH NOTIFICATION SERVICE
/// ============================================================

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ==========================================================
  /// INITIALIZE PUSH NOTIFICATIONS
  /// ==========================================================

  Future<void> init() async {
    // ----------------------------------------------------------
    // Request notification permission
    // ----------------------------------------------------------

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // ----------------------------------------------------------
    // Get Firebase Cloud Messaging token
    // ----------------------------------------------------------

    final token = await FirebaseMessaging.instance.getToken();

    debugPrint('Firebase Token: $token');

    // ----------------------------------------------------------
    // Register background message handler
    // ----------------------------------------------------------

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ----------------------------------------------------------
    // Setup local notifications
    // ----------------------------------------------------------

    await setupFlutterNotifications();

    // ----------------------------------------------------------
    // Handle notification when app is opened from terminated
    // state
    // ----------------------------------------------------------

    final RemoteMessage? initialMessage = await messaging.getInitialMessage();

    handleMessage(initialMessage);

    // ----------------------------------------------------------
    // Handle notification when app is opened from background
    // ----------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // ----------------------------------------------------------
    // Handle foreground notifications
    // ----------------------------------------------------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
    });
  }

  /// ==========================================================
  /// HANDLE NOTIFICATION CLICK
  /// ==========================================================

  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      return;
    }

    debugPrint('Notification clicked: ${message.messageId}');

    debugPrint('Notification data: ${message.data}');

    // ----------------------------------------------------------
    // Add your navigation logic here.
    //
    // Example:
    //
    // final screen = message.data['screen'];
    //
    // if (screen == 'chat') {
    //   // Navigate to chat
    // }
    //
    // ----------------------------------------------------------
  }

  /// ==========================================================
  /// SETUP FLUTTER LOCAL NOTIFICATIONS
  /// ==========================================================

  Future<void> setupFlutterNotifications() async {
    // ----------------------------------------------------------
    // Android notification channel
    // ----------------------------------------------------------

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // ----------------------------------------------------------
    // Create Android notification channel
    // ----------------------------------------------------------

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // ----------------------------------------------------------
    // Android initialization
    // ----------------------------------------------------------

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');

    // ----------------------------------------------------------
    // iOS initialization
    // ----------------------------------------------------------

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // ----------------------------------------------------------
    // Combined initialization settings
    // ----------------------------------------------------------

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // ----------------------------------------------------------
    // Initialize local notification plugin
    //
    // flutter_local_notifications 22.x uses:
    // settings: initializationSettings
    // ----------------------------------------------------------

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification clicked');

        debugPrint('Payload: ${response.payload}');
      },
    );

    // ----------------------------------------------------------
    // Request Android notification permission
    // ----------------------------------------------------------

    if (!kIsWeb) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    // ----------------------------------------------------------
    // iOS foreground notification presentation
    // ----------------------------------------------------------

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// ==========================================================
  /// SHOW FOREGROUND FIREBASE NOTIFICATION
  /// ==========================================================

  Future<void> showFlutterNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    final AndroidNotification? android = message.notification?.android;

    // ----------------------------------------------------------
    // Android foreground notification
    // ----------------------------------------------------------

    if (notification != null && android != null && !kIsWeb) {
      await flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'launch_background',
          ),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    }
  }
}
