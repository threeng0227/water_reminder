import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import '../core/l10n/app_strings.dart';
import '../data/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channel = MethodChannel('water_reminder/timezone');

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      final tzName =
          await _channel.invokeMethod<String>('getTimezone') ?? 'UTC';
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // fallback: leave as UTC — better than crashing
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation handled via app-level router on resume
  }

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? false;
    return granted;
  }

  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.isEnabled) return;

    final s = await _getStrings();
    final notifDetails = NotificationDetails(android: _androidChannel());

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      if (!reminder.weekdays[dayIndex]) continue;

      final scheduledDate =
          _nextWeekday(dayIndex + 1, reminder.hour, reminder.minute);
      final notifId = _notifId(reminder.id, dayIndex);

      await _plugin.zonedSchedule(
        notifId,
        '💧 ${reminder.label}',
        _randomMotivation(s),
        scheduledDate,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    for (int i = 0; i < 7; i++) {
      await _plugin.cancel(_notifId(reminderId, i));
    }
  }

  Future<void> scheduleAllReminders(List<Reminder> reminders) async {
    await _plugin.cancelAll();
    for (final r in reminders) {
      if (r.isEnabled) await scheduleReminder(r);
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      999,
      title,
      body,
      NotificationDetails(android: _androidChannel()),
    );
  }

  Future<void> scheduleSmartReminders({
    required int intervalMinutes,
    required int wakeHour,
    required int sleepHour,
  }) async {
    final s = await _getStrings();
    final now = tz.TZDateTime.now(tz.local);
    int notifId = 5000;

    // Build the first candidate at wakeHour today, then advance by interval
    // until we find a slot strictly in the future.
    tz.TZDateTime candidate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, wakeHour, 0);

    // Advance past any slots already in the past.
    while (!candidate.isAfter(now)) {
      candidate = candidate.add(Duration(minutes: intervalMinutes));
    }

    final endOfDay = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, sleepHour, 0);

    // If nothing left today, start from wakeHour tomorrow.
    if (!candidate.isBefore(endOfDay)) {
      final tomorrow = now.add(const Duration(days: 1));
      candidate = tz.TZDateTime(
          tz.local, tomorrow.year, tomorrow.month, tomorrow.day, wakeHour, 0);
    }

    while (notifId < 5050) {
      // Stop scheduling once we exceed sleep time on that day.
      final dayEnd = tz.TZDateTime(
          tz.local, candidate.year, candidate.month, candidate.day, sleepHour, 0);
      if (!candidate.isBefore(dayEnd)) break;

      await _plugin.zonedSchedule(
        notifId++,
        s.notifTitle,
        _randomMotivation(s),
        candidate,
        NotificationDetails(android: _androidChannel()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      candidate = candidate.add(Duration(minutes: intervalMinutes));
    }
  }

  Future<void> cancelSmartReminders() async {
    for (int i = 5000; i < 5050; i++) {
      await _plugin.cancel(i);
    }
  }

  AndroidNotificationDetails _androidChannel() =>
      AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF00C2CB),
        playSound: true,
        enableVibration: true,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notifId(String reminderId, int dayIndex) =>
      reminderId.hashCode.abs() % 100000 + dayIndex;

  Future<AppStrings> _getStrings() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('app_locale') ?? 'en';
    return AppStrings(locale);
  }

  String _randomMotivation(AppStrings s) {
    final msgs = s.motivationalMessages;
    return msgs[Random().nextInt(msgs.length)];
  }
}
