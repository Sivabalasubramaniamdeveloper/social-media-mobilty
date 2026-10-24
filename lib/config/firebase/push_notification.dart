import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mineai/config/supabase/supabase.config.dart';
import 'package:mineai/core/constants/app_strings.dart';
import 'package:mineai/core/logger/app_logger.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint('FCM Background message received: ${message.messageId} - ${message.notification?.title}');
}

/// Central Firebase Cloud Messaging service for handling push notifications,
/// token management, and notification tap routing.
class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._();
  PushNotificationService._();

  factory PushNotificationService() => instance;

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Callback when a notification is clicked/opened
  static void Function(Map<String, dynamic> data)? onNotificationClicked;

  /// Initialize Firebase Messaging
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          debugPrint('Firebase not available for FCM: $e');
          return;
        }
      }

      _messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM authorization status: ${settings.authorizationStatus}');

      // Setup local notifications channel for Android foreground display
      await _setupLocalNotifications();

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Listen for incoming foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen for notification open events when app is running in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM opened from background: ${message.data}');
        _routeNotification(message.data);
      });

      // Check if opened from a terminated state
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM opened from terminated state: ${initialMessage.data}');
        _routeNotification(initialMessage.data);
      }

      // Fetch and sync FCM token
      await refreshFcmToken();

      // Listen for token refreshes
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _syncTokenToBackend(newToken);
      });

      _initialized = true;
      CustomAppLogger.info('PushNotificationService initialized successfully', 'FCM');
    } catch (e, stack) {
      debugPrint('PushNotificationService initialization error: $e');
      CustomAppLogger.error('Failed to init FCM: $e', 'PushNotificationService', stack);
    }
  }

  /// Setup Android notification channel for foreground display
  Future<void> _setupLocalNotifications() async {
    const channel = AndroidNotificationChannel(
      'mineai_push_channel',
      'Mine AI Notifications',
      description: 'Instant updates for tickets, budget alerts, and AI insights',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _routeNotification(data);
          } catch (_) {}
        }
      },
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle incoming message in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null && !kIsWeb) {
      await _localNotifications.show(
        id: message.hashCode,
        title: notification.title ?? AppStrings.appName,
        body: notification.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'mineai_push_channel',
            'Mine AI Notifications',
            channelDescription: 'Instant updates for tickets, budget alerts, and AI insights',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Route notification payload
  void _routeNotification(Map<String, dynamic> data) {
    if (onNotificationClicked != null) {
      onNotificationClicked!(data);
    }
  }

  /// Retrieve and persist FCM token
  Future<String?> refreshFcmToken() async {
    if (_messaging == null) return null;
    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint('FCM Registration Token: $_fcmToken');
      if (_fcmToken != null) {
        await _syncTokenToBackend(_fcmToken!);
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('Error retrieving FCM token: $e');
      return null;
    }
  }

  /// Sync token to Supabase / Backend for user
  Future<void> _syncTokenToBackend(String token) async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        // Save FCM token in user_devices table
        await SupabaseConfig.client.from('user_devices').upsert({
          'user_id': user.id,
          'device_id': user.id,
          'push_token': token,
          'is_active': true,
          'last_active_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,device_id');
      }
    } catch (e) {
      debugPrint('FCM token backend sync note: $e');
    }
  }
}
