import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/flashcards/domain/flashcard_schedule_planner.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';

void main() {
  final day = DateTime(2026, 8, 17);

  test('fixed mode returns exactly the configured times, sorted', () {
    final planner = FlashcardSchedulePlanner();

    final times = planner.timesForDay(
      day: day,
      volume: FlashcardVolume.medium,
      frequencyMode: FlashcardFrequencyMode.fixed,
      fixedTimes: ['20:00', '09:00', '13:30'],
    );

    expect(times, [
      DateTime(2026, 8, 17, 9, 0),
      DateTime(2026, 8, 17, 13, 30),
      DateTime(2026, 8, 17, 20, 0),
    ]);
  });

  test('random mode returns one time per notificationsPerDay', () {
    final planner = FlashcardSchedulePlanner(random: Random(7));

    for (final volume in FlashcardVolume.values) {
      final times = planner.timesForDay(
        day: day,
        volume: volume,
        frequencyMode: FlashcardFrequencyMode.random,
        fixedTimes: const [],
      );
      expect(times, hasLength(volume.notificationsPerDay));
    }
  });

  test('random mode stays within waking hours and is sorted', () {
    final planner = FlashcardSchedulePlanner(random: Random(99));

    final times = planner.timesForDay(
      day: day,
      volume: FlashcardVolume.high,
      frequencyMode: FlashcardFrequencyMode.random,
      fixedTimes: const [],
    );

    expect(times, hasLength(FlashcardVolume.high.notificationsPerDay));
    for (final t in times) {
      expect(
        t.hour,
        greaterThanOrEqualTo(FlashcardSchedulePlanner.wakingStartHour),
      );
      expect(t.hour, lessThan(FlashcardSchedulePlanner.wakingEndHour));
    }
    final sorted = [...times]..sort();
    expect(times, sorted);
  });

  test('random mode results land on the requested day', () {
    final planner = FlashcardSchedulePlanner(random: Random(3));

    final times = planner.timesForDay(
      day: day,
      volume: FlashcardVolume.low,
      frequencyMode: FlashcardFrequencyMode.random,
      fixedTimes: const [],
    );

    for (final t in times) {
      expect(t.year, day.year);
      expect(t.month, day.month);
      expect(t.day, day.day);
    }
  });
}
