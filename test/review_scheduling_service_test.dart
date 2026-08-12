import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/assessment/domain/models/attempt_outcome.dart';
import 'package:teacher/features/review/domain/models/review_schedule.dart';
import 'package:teacher/features/review/domain/review_scheduling_service.dart';

void main() {
  final service = ReviewSchedulingService();

  group('ReviewSchedulingService', () {
    test('a poor review resets the interval to the short poor interval', () {
      final current = ReviewSchedule(
        conceptId: 'python-closures',
        dueAt: DateTime.now(),
        intervalDays: 30,
        lastReviewedAt: DateTime.now(),
        reviewCount: 4,
      );

      final next = service.scheduleNext(
        current: current,
        performance: PerformanceBucket.poor,
      );

      expect(next.intervalDays, service.poorIntervalDays);
    });

    test('a good review roughly doubles the interval', () {
      final current = ReviewSchedule.initial('python-closures')
          .copyWithInterval(4);

      final next = service.scheduleNext(
        current: current,
        performance: PerformanceBucket.good,
      );

      expect(next.intervalDays, 8);
      expect(next.reviewCount, current.reviewCount + 1);
    });

    test('an excellent review grows the interval faster than a good one', () {
      final current = ReviewSchedule.initial('python-closures')
          .copyWithInterval(4);

      final goodNext = service.scheduleNext(
        current: current,
        performance: PerformanceBucket.good,
      );
      final excellentNext = service.scheduleNext(
        current: current,
        performance: PerformanceBucket.excellent,
      );

      expect(excellentNext.intervalDays, greaterThan(goodNext.intervalDays));
    });

    test('the interval never exceeds the configured cap', () {
      final current = ReviewSchedule.initial('python-closures')
          .copyWithInterval(80);

      final next = service.scheduleNext(
        current: current,
        performance: PerformanceBucket.excellent,
      );

      expect(next.intervalDays, lessThanOrEqualTo(service.maxIntervalDays));
    });

    test(
      'a first-time good review starts from a sensible default, not zero',
      () {
        final current = ReviewSchedule.initial('python-closures');

        final next = service.scheduleNext(
          current: current,
          performance: PerformanceBucket.good,
        );

        expect(next.intervalDays, greaterThanOrEqualTo(1));
      },
    );
  });
}

extension on ReviewSchedule {
  ReviewSchedule copyWithInterval(int days) => ReviewSchedule(
    conceptId: conceptId,
    dueAt: dueAt,
    intervalDays: days,
    lastReviewedAt: lastReviewedAt,
    reviewCount: reviewCount,
  );
}
