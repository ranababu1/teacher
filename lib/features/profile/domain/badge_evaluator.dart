import 'models/badge.dart';
import 'models/experience_level.dart';

/// Evaluates which collectible badges a learner has unlocked. Deliberately
/// derived live from monotonic counts (nothing is ever "un-completed" in
/// this codebase) rather than persisted, and uses longest streak rather
/// than current streak for streak badges — otherwise a badge would
/// disappear the day after a streak breaks. See instructions.md
/// sections 44-45.
class BadgeEvaluator {
  List<Badge> evaluate({
    required int coursesCompleted,
    required int longestStreak,
    required int codingChallengesAttempted,
    required int lessonsCompleted,
    required ExperienceLevel experienceLevel,
    required int quizzesPassed,
    required int perfectQuizzes,
  }) {
    final badges = <Badge>[];

    void add(BadgeId id, String emoji, String label, String description) {
      badges.add(
        Badge(id: id, emoji: emoji, label: label, description: description),
      );
    }

    // Streaks
    if (longestStreak >= 3) {
      add(BadgeId.threeDayStreak, '🔥', 'Spark', '3 day streak');
    }
    if (longestStreak >= 7) {
      add(BadgeId.sevenDayStreak, '🔥', 'On Fire', '7 day streak');
    }
    if (longestStreak >= 14) {
      add(BadgeId.fourteenDayStreak, '🔥', 'Blazing', '14 day streak');
    }
    if (longestStreak >= 30) {
      add(BadgeId.thirtyDayStreak, '🔥', 'Unstoppable', '30 day streak');
    }
    if (longestStreak >= 100) {
      add(
        BadgeId.hundredDayStreak,
        '🔥',
        'Legendary Streak',
        '100 day streak',
      );
    }

    // XP / experience level milestones
    if (experienceLevel.index >= ExperienceLevel.beginnerDeveloper.index) {
      add(
        BadgeId.beginnerDeveloperReached,
        '🎖️',
        'Rising Star',
        'Reached Beginner Developer',
      );
    }
    if (experienceLevel.index >= ExperienceLevel.juniorDeveloper.index) {
      add(
        BadgeId.juniorDeveloperReached,
        '🎖️',
        'Leveling Up',
        'Reached Junior Developer',
      );
    }
    if (experienceLevel.index >= ExperienceLevel.intermediateDeveloper.index) {
      add(
        BadgeId.intermediateDeveloperReached,
        '🏆',
        'Halfway Hero',
        'Reached Intermediate Developer',
      );
    }
    if (experienceLevel.index >= ExperienceLevel.advancedDeveloper.index) {
      add(
        BadgeId.advancedDeveloperReached,
        '👑',
        'Elite Developer',
        'Reached Advanced Developer',
      );
    }

    // Lessons
    if (lessonsCompleted >= 10) {
      add(BadgeId.tenLessonsCompleted, '📘', 'Bookworm', '10 lessons completed');
    }
    if (lessonsCompleted >= 50) {
      add(BadgeId.fiftyLessonsCompleted, '📗', 'Scholar', '50 lessons completed');
    }
    if (lessonsCompleted >= 200) {
      add(
        BadgeId.twoHundredLessonsCompleted,
        '📕',
        'Sage',
        '200 lessons completed',
      );
    }

    // Courses
    if (coursesCompleted >= 1) {
      add(
        BadgeId.firstCourse,
        '🥇',
        'First Steps',
        'Completed your first course',
      );
    }
    if (coursesCompleted >= 3) {
      add(
        BadgeId.threeCoursesCompleted,
        '🎓',
        'Triple Threat',
        'Completed 3 courses',
      );
    }
    if (coursesCompleted >= 5) {
      add(
        BadgeId.fiveCoursesCompleted,
        '👑',
        'Course Collector',
        'Completed 5 courses',
      );
    }

    // Coding challenges
    if (codingChallengesAttempted >= 25) {
      add(
        BadgeId.twentyFiveCodingChallenges,
        '💻',
        'Code Explorer',
        '25 coding challenges',
      );
    }
    if (codingChallengesAttempted >= 100) {
      add(
        BadgeId.hundredCodingChallenges,
        '💻',
        'Code Master',
        '100 coding challenges',
      );
    }

    // Quizzes (topic-gating module tests)
    if (quizzesPassed >= 1) {
      add(
        BadgeId.firstQuizPassed,
        '✅',
        'Quiz Taker',
        'Passed your first topic quiz',
      );
    }
    if (quizzesPassed >= 10) {
      add(BadgeId.tenQuizzesPassed, '🧠', 'Quiz Whiz', 'Passed 10 topic quizzes');
    }
    if (perfectQuizzes >= 1) {
      add(
        BadgeId.perfectQuiz,
        '🎯',
        'Perfect Score',
        'Scored 100% on a topic quiz',
      );
    }
    if (perfectQuizzes >= 5) {
      add(
        BadgeId.fivePerfectQuizzes,
        '🎯',
        'Flawless',
        'Scored 100% on 5 topic quizzes',
      );
    }

    return badges;
  }
}
