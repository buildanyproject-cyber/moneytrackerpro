import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

// ============================================================
// Notification Service — Local push notifications for
// budget alerts, bill reminders, and recurring transactions
// ============================================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ─────────── Initialization ───────────

  Future<void> init() async {
    if (kIsWeb) return;

    // Initialize Timezone for Scheduled Notifications
    tz.initializeTimeZones();
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = (tzInfo is String)
          ? tzInfo
          : tzInfo.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions on Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Request exact alarm permission on Android 12+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap — can navigate to specific screen
  }

  // ─────────── Show Immediate Notification ───────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'moneytracker_channel',
      'MoneyTracker Pro',
      channelDescription: 'Financial notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  // ─────────── Schedule Notification (with alarm sound) ───────────

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;

    final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Don't schedule if the date is already in the past
    if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'moneytracker_alarm_channel',
      'MoneyTracker Reminders',
      channelDescription: 'Alarm notifications for bill reminders',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // ─────────── Schedule Alarm Notification ───────────
  /// Schedule with default system alarm sound (fallback if custom sound missing)

  Future<void> scheduleAlarmNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;

    final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final Int32List insistentFlag = Int32List.fromList(<int>[4]);

    final androidDetails = AndroidNotificationDetails(
      'moneytracker_alarm_channel_v3',
      'MoneyTracker Alarms',
      channelDescription: 'Alarm-style notifications for reminders',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      additionalFlags: insistentFlag,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // ─────────── Budget Alert ───────────

  Future<void> showBudgetAlert(
    String categoryName,
    double spent,
    double budget,
  ) async {
    await showNotification(
      id: categoryName.hashCode,
      title: '⚠️ Budget Alert',
      body:
          'You\'ve exceeded your $categoryName budget! Spent: ₹${spent.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}',
    );
  }

  // ─────────── Cancel ───────────

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
