import 'models/badge.dart';

/// Evaluates which badges a learner has unlocked. Deliberately derived
/// live from monotonic counts (nothing is ever "un-completed" in this
/// codebase) rather than persisted, and uses longest streak rather than
/// current streak for streak badges — otherwise a badge would disappear
/// the day after a streak breaks. See instructions.md sections 44-45.
class BadgeEvaluator {
  List<Badge> evaluate({
    required int coursesCompleted,
    required int longestStreak,
    required int codingChallengesAttempted,
    required int lessonsCompleted,
  }) {
    final badges = <Badge>[];

    if (coursesCompleted >= 1) {
      badges.add(
        const Badge(id: BadgeId.firstCourse, emoji: '🥇', label: 'First Course'),
      );
    }
    if (coursesCompleted >= 3) {
      badges.add(
        const Badge(
          id: BadgeId.threeCoursesCompleted,
          emoji: '🎓',
          label: '3 Courses Completed',
        ),
      );
    }
    if (longestStreak >= 7) {
      badges.add(
        const Badge(id: BadgeId.sevenDayStreak, emoji: '🔥', label: '7 Day Streak'),
      );
    }
    if (longestStreak >= 30) {
      badges.add(
        const Badge(
          id: BadgeId.thirtyDayStreak,
          emoji: '🔥',
          label: '30 Day Streak',
        ),
      );
    }
    if (codingChallengesAttempted >= 25) {
      badges.add(
        const Badge(
          id: BadgeId.twentyFiveCodingChallenges,
          emoji: '💻',
          label: '25 Coding Challenges',
        ),
      );
    }
    if (codingChallengesAttempted >= 100) {
      badges.add(
        const Badge(
          id: BadgeId.hundredCodingChallenges,
          emoji: '💻',
          label: '100 Coding Challenges',
        ),
      );
    }
    if (lessonsCompleted >= 10) {
      badges.add(
        const Badge(
          id: BadgeId.tenLessonsCompleted,
          emoji: '📘',
          label: '10 Lessons Completed',
        ),
      );
    }
    if (lessonsCompleted >= 50) {
      badges.add(
        const Badge(
          id: BadgeId.fiftyLessonsCompleted,
          emoji: '📗',
          label: '50 Lessons Completed',
        ),
      );
    }

    return badges;
  }
}
