import 'package:equatable/equatable.dart';

/// Attempts and successes on one calendar day.
class DailyActivity extends Equatable {
  const DailyActivity({
    required this.day,
    required this.attempts,
    required this.successes,
  });

  /// Local midnight.
  final DateTime day;
  final int attempts;
  final int successes;

  @override
  List<Object?> get props => [day, attempts, successes];
}

/// Success rate over one 7-day window (oldest first in [LearningAnalytics]).
class WeeklyAccuracy extends Equatable {
  const WeeklyAccuracy({
    required this.weekStart,
    required this.attempts,
    required this.accuracy,
  });

  final DateTime weekStart;
  final int attempts;

  /// 0.0-1.0, or `null` when there were no attempts that week.
  final double? accuracy;

  @override
  List<Object?> get props => [weekStart, attempts, accuracy];
}

/// Accuracy for one course.
class CourseAccuracy extends Equatable {
  const CourseAccuracy({
    required this.learningPathId,
    required this.title,
    required this.attempts,
    required this.accuracy,
  });

  final String learningPathId;
  final String title;
  final int attempts;
  final double accuracy;

  @override
  List<Object?> get props => [learningPathId, attempts, accuracy];
}

/// A concept the learner keeps getting wrong.
class WeakConcept extends Equatable {
  const WeakConcept({
    required this.conceptId,
    required this.title,
    required this.learningPathId,
    required this.moduleId,
    required this.attempts,
    required this.accuracy,
  });

  final String conceptId;
  final String title;
  final String learningPathId;
  final String moduleId;
  final int attempts;
  final double accuracy;

  @override
  List<Object?> get props => [conceptId, attempts, accuracy];
}

enum DayPart {
  morning('Morning (5-12)'),
  afternoon('Afternoon (12-17)'),
  evening('Evening (17-22)'),
  night('Night (22-5)');

  const DayPart(this.label);

  final String label;

  static DayPart of(DateTime t) => switch (t.hour) {
    >= 5 && < 12 => morning,
    >= 12 && < 17 => afternoon,
    >= 17 && < 22 => evening,
    _ => night,
  };
}

/// Real, attempt-history-based learning analytics for the Analytics screen.
class LearningAnalytics extends Equatable {
  const LearningAnalytics({
    required this.totalAttempts,
    required this.last28Days,
    required this.weekly,
    required this.courses,
    required this.weakConcepts,
    required this.attemptsByDayPart,
  });

  final int totalAttempts;

  /// Exactly 28 entries, oldest first, ending today.
  final List<DailyActivity> last28Days;

  /// Exactly 4 entries, oldest first, the last ending today.
  final List<WeeklyAccuracy> weekly;

  /// Most-practised first.
  final List<CourseAccuracy> courses;

  /// Lowest accuracy first (at most 5).
  final List<WeakConcept> weakConcepts;

  final Map<DayPart, int> attemptsByDayPart;

  bool get isEmpty => totalAttempts == 0;

  int get activeDaysLast28 => last28Days.where((d) => d.attempts > 0).length;

  /// The part of the day with the most attempts, or `null` with no data.
  DayPart? get favouriteDayPart {
    if (attemptsByDayPart.values.every((v) => v == 0)) return null;
    return attemptsByDayPart.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
  }

  @override
  List<Object?> get props => [
    totalAttempts,
    last28Days,
    weekly,
    courses,
    weakConcepts,
    attemptsByDayPart,
  ];
}
