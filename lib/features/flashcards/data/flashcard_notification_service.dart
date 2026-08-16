import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../app/router.dart';
import '../../../core/constants/routes.dart';
import '../../../core/services/app_logger.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/flashcard_schedule_planner.dart';
import '../domain/models/flash_card.dart';

/// Schedules and delivers weekly-flashcard local notifications.
///
/// Deliberately uses [AndroidScheduleMode.inexactAllowWhileIdle] rather
/// than an exact alarm: a flash card arriving a few minutes off from its
/// planned random time is fine, and staying inexact avoids ever asking
/// for the "Alarms & reminders" special permission — this is a review
/// nudge, not an alarm clock. Similarly skips `fullScreenIntent` (the
/// lockscreen-takeover behavior used by call/alarm apps) — "full screen"
/// here means the in-app card view's layout, not an intrusive interrupt.
class FlashcardNotificationService {
  FlashcardNotificationService({FlashcardSchedulePlanner? planner})
    : _planner = planner ?? FlashcardSchedulePlanner();

  static const _channelId = 'weekly_flashcards';
  static const _channelName = 'Weekly flash cards';
  static const _channelDescription =
      "Byte-sized reviews of what you've learned this week.";
  static const _notificationTitle = 'Quick flash card';

  /// Notifications are (re)planned this many days ahead each time the
  /// schedule refreshes, so they keep firing even if the app isn't opened
  /// again for a while.
  static const _scheduleDays = 7;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FlashcardSchedulePlanner _planner;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      AppLogger.warning(
        'Could not resolve local timezone for flashcard scheduling, '
        'defaulting to UTC: $e',
      );
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Requests the Android 13+ runtime notification permission. Returns
  /// `true` on older Android versions where no prompt is needed.
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Cancels anything previously scheduled and, if [pool] is non-empty,
  /// plans the next [_scheduleDays] days of notifications per [volume]
  /// and [frequencyMode], cycling through [pool] so the week's cards
  /// rotate rather than repeating the same one.
  Future<void> scheduleWeek({
    required List<FlashCard> pool,
    required FlashcardVolume volume,
    required FlashcardFrequencyMode frequencyMode,
    required List<String> fixedTimes,
  }) async {
    await _plugin.cancelAll();
    if (pool.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    var cardIndex = 0;
    var notificationId = 0;

    for (var dayOffset = 0; dayOffset < _scheduleDays; dayOffset++) {
      final day = now.add(Duration(days: dayOffset));
      final times = _planner.timesForDay(
        day: day,
        volume: volume,
        frequencyMode: frequencyMode,
        fixedTimes: fixedTimes,
      );

      for (final time in times) {
        final scheduledDate = tz.TZDateTime(
          tz.local,
          time.year,
          time.month,
          time.day,
          time.hour,
          time.minute,
        );
        if (scheduledDate.isBefore(now)) continue;

        final card = pool[cardIndex % pool.length];
        cardIndex++;

        await _plugin.zonedSchedule(
          id: notificationId++,
          title: _notificationTitle,
          body: card.front,
          scheduledDate: scheduledDate,
          payload: jsonEncode(card.toJson()),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Fires a single flash card notification a few seconds out — used by
  /// the Developer settings "send test notification" action so the whole
  /// tap-to-open flow can be verified without waiting for a real
  /// scheduled time.
  Future<void> sendTestNotification(FlashCard card) async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 5));

    await _plugin.zonedSchedule(
      id: -1,
      title: _notificationTitle,
      body: card.front,
      scheduledDate: scheduledDate,
      payload: jsonEncode(card.toJson()),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final card = FlashCard.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).push(Routes.flashCard, extra: card);
      }
    } catch (e) {
      AppLogger.warning('Could not open tapped flashcard notification: $e');
    }
  }
}
