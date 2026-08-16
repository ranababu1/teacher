import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/profile/domain/streak_service.dart';

void main() {
  final service = StreakService();
  final today = DateTime(2026, 8, 16);

  Set<DateTime> daysBefore(List<int> offsets) =>
      offsets.map((o) => today.subtract(Duration(days: o))).toSet();

  group('currentStreak', () {
    test('empty history returns 0', () {
      expect(service.currentStreak(activeDays: {}, now: today), 0);
    });

    test('active today counts today', () {
      final activeDays = daysBefore([0]);
      expect(service.currentStreak(activeDays: activeDays, now: today), 1);
    });

    test('active yesterday only still counts (today not yet opened)', () {
      final activeDays = daysBefore([1]);
      expect(service.currentStreak(activeDays: activeDays, now: today), 1);
    });

    test('a gap two days back breaks the streak entirely', () {
      final activeDays = daysBefore([2, 3, 4]);
      expect(service.currentStreak(activeDays: activeDays, now: today), 0);
    });

    test('counts back through consecutive active days', () {
      final activeDays = daysBefore([0, 1, 2, 3]);
      expect(service.currentStreak(activeDays: activeDays, now: today), 4);
    });
  });

  group('longestStreak', () {
    test('empty history returns 0', () {
      expect(service.longestStreak(activeDays: {}), 0);
    });

    test('a broken-then-resumed history finds the longest run, not the trailing one', () {
      // A 5-day run far in the past, a gap, then a 2-day run ending today.
      final activeDays = daysBefore([0, 1, 20, 21, 22, 23, 24]);
      expect(service.longestStreak(activeDays: activeDays), 5);
    });

    test('a single active day has a longest streak of 1', () {
      final activeDays = daysBefore([0]);
      expect(service.longestStreak(activeDays: activeDays), 1);
    });
  });
}
