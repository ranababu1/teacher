import 'dart:math';

import '../../settings/domain/settings_models.dart';

/// Pure computation of "what times today should a flash card notification
/// fire" — kept separate from the plugin-backed scheduler
/// (`FlashcardNotificationService`) so the actual decision logic is
/// testable without platform channels.
class FlashcardSchedulePlanner {
  FlashcardSchedulePlanner({Random? random}) : _random = random ?? Random();

  /// Notifications are only spread across waking hours — nobody wants a
  /// flash card at 3am.
  static const wakingStartHour = 8;
  static const wakingEndHour = 22;

  final Random _random;

  /// Returns the local times (as full [DateTime]s on [day]'s date) a
  /// flashcard notification should fire that day, per [volume] and
  /// [frequencyMode]. Always sorted ascending.
  List<DateTime> timesForDay({
    required DateTime day,
    required FlashcardVolume volume,
    required FlashcardFrequencyMode frequencyMode,
    required List<String> fixedTimes,
  }) {
    final date = DateTime(day.year, day.month, day.day);

    if (frequencyMode == FlashcardFrequencyMode.fixed) {
      final times = fixedTimes.map((t) => _parseTimeOnto(date, t)).toList();
      times.sort();
      return times;
    }

    final windowMinutes = (wakingEndHour - wakingStartHour) * 60;
    final count = volume.notificationsPerDay;
    final times = <DateTime>[
      for (var i = 0; i < count; i++)
        date.add(
          Duration(
            hours: wakingStartHour,
            minutes: _random.nextInt(windowMinutes),
          ),
        ),
    ];
    times.sort();
    return times;
  }

  DateTime _parseTimeOnto(DateTime date, String hhMm) {
    final parts = hhMm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
