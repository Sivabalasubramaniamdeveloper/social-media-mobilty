import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // ============================================================
  // TIMEZONE INITIALIZATION
  // ============================================================

  static Future<void> initializeTimeZone() async {
    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Get device local timezone
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    // Set device timezone as timezone.local
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  }

  // ============================================================
  // LOCAL NOTIFICATION INITIALIZATION
  // ============================================================

  static Future<void> localInit() async {
    // Initialize timezone BEFORE scheduling notifications
    await initializeTimeZone();

    // ----------------------------------------------------------
    // Android initialization
    // ----------------------------------------------------------

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ----------------------------------------------------------
    // iOS initialization
    // ----------------------------------------------------------

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    // ----------------------------------------------------------
    // Combined initialization settings
    // ----------------------------------------------------------

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // ----------------------------------------------------------
    // Initialize notification plugin
    // ----------------------------------------------------------

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationClick(details.payload);
      },
    );

    // ----------------------------------------------------------
    // Check whether app was launched from notification
    // ----------------------------------------------------------

    final NotificationAppLaunchDetails? details =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationClick(details?.notificationResponse?.payload);
    }

    // ----------------------------------------------------------
    // Android notification permission
    // ----------------------------------------------------------

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // ----------------------------------------------------------
    // iOS notification permission
    // ----------------------------------------------------------

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ============================================================
  // GET INITIAL NOTIFICATION
  // ============================================================

  static Future<String> getInitNotif() async {
    final NotificationAppLaunchDetails? details =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      final String? payload = details?.notificationResponse?.payload;

      if (payload == null) {
        return 'dashboard';
      }

      if (payload == '0' ||
          payload == '-1' ||
          payload == '-2' ||
          payload.startsWith('file://') ||
          payload.endsWith('.pdf') ||
          payload.endsWith('.jpg')) {
        return 'dashboard';
      }

      return 'dashboard';
    }

    return 'dashboard';
  }

  // ============================================================
  // GET NOTIFICATION PAYLOAD
  // ============================================================

  static Future<String?> getNotificationPayload() async {
    final NotificationAppLaunchDetails? details =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    return details?.notificationResponse?.payload;
  }

  // ============================================================
  // HANDLE NOTIFICATION CLICK
  // ============================================================

  static void _handleNotificationClick(String? payload) {
    if (payload == null) {
      return;
    }

    // Add your navigation logic here.
    //
    // Example:
    //
    // if (payload.startsWith('file://') ||
    //     payload.endsWith('.pdf') ||
    //     payload.endsWith('.jpg')) {
    //
    //   // Handle file
    //
    // } else if (payload == '0' ||
    //            payload == '-1' ||
    //            payload == '-2') {
    //
    //   // Navigate to dashboard
    //
    // } else {
    //
    //   // Navigate to dashboard
    //
    // }
  }

  // ============================================================
  // SHOW INSTANT NOTIFICATION
  // ============================================================

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // ============================================================
  // SCHEDULE REPEATING NOTIFICATION
  // ============================================================

  static Future<void> scheduleRepeatingNotification(
    String title,
    String body,
    DateTime scheduledDate,
    DateTimeComponents dateTimeComponent,
    int id,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel',
          'Recurring Notifications',
          channelDescription: 'Channel for recurring notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(''),
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      matchDateTimeComponents: dateTimeComponent,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: id.toString(),
    );
  }

  // ============================================================
  // SCHEDULE ONE-TIME NOTIFICATION
  // ============================================================

  static Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledDate,
    int id,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  // ============================================================
  // PERIODIC NOTIFICATION
  // ============================================================

  static Future<void> showPerodicNotification({
    required String titile,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel 2',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id: 1,
      title: titile,
      body: body,
      repeatInterval: RepeatInterval.everyMinute,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: payload,
    );
  }

  // ============================================================
  // CANCEL NOTIFICATION
  // ============================================================

  static Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  // ============================================================
  // CANCEL ALL NOTIFICATIONS
  // ============================================================

  static Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
