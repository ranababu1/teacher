import '../../assessment/domain/models/attempt_outcome.dart';
import 'models/review_schedule.dart';

/// Deliberately simple spaced-repetition scheduling — see instructions.md
/// section 23: "Do not implement a complex algorithm prematurely. Start
/// with a configurable scheduling service so the algorithm can evolve
/// later." The multipliers/caps below are the only things a future,
/// smarter algorithm (e.g. SM-2-style) would need to change.
class ReviewSchedulingService {
  const ReviewSchedulingService({
    this.poorIntervalDays = 1,
    this.goodMultiplier = 2.0,
    this.excellentMultiplier = 3.0,
    this.maxIntervalDays = 90,
  });

  final int poorIntervalDays;
  final double goodMultiplier;
  final double excellentMultiplier;
  final int maxIntervalDays;

  ReviewSchedule scheduleNext({
    required ReviewSchedule current,
    required PerformanceBucket performance,
  }) {
    final now = DateTime.now();
    final previousInterval = current.intervalDays;

    final nextInterval = switch (performance) {
      PerformanceBucket.poor => poorIntervalDays,
      PerformanceBucket.good =>
        (previousInterval <= 0 ? 1 : previousInterval * goodMultiplier)
            .round()
            .clamp(1, maxIntervalDays),
      PerformanceBucket.excellent =>
        (previousInterval <= 0 ? 3 : previousInterval * excellentMultiplier)
            .round()
            .clamp(1, maxIntervalDays),
    };

    return ReviewSchedule(
      conceptId: current.conceptId,
      dueAt: now.add(Duration(days: nextInterval)),
      intervalDays: nextInterval,
      lastReviewedAt: now,
      reviewCount: current.reviewCount + 1,
    );
  }
}
