import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/profile/domain/badge_evaluator.dart';
import 'package:teacher/features/profile/domain/models/badge.dart';
import 'package:teacher/features/profile/domain/models/experience_level.dart';

void main() {
  final evaluator = BadgeEvaluator();

  List<Badge> evaluate({
    int coursesCompleted = 0,
    int longestStreak = 0,
    int codingChallengesAttempted = 0,
    int lessonsCompleted = 0,
    ExperienceLevel experienceLevel = ExperienceLevel.newDeveloper,
    int quizzesPassed = 0,
    int perfectQuizzes = 0,
  }) => evaluator.evaluate(
    coursesCompleted: coursesCompleted,
    longestStreak: longestStreak,
    codingChallengesAttempted: codingChallengesAttempted,
    lessonsCompleted: lessonsCompleted,
    experienceLevel: experienceLevel,
    quizzesPassed: quizzesPassed,
    perfectQuizzes: perfectQuizzes,
  );

  test('no badges when every count is zero', () {
    expect(evaluate(), isEmpty);
  });

  test('First Course unlocks at 1 course, not before', () {
    expect(evaluate(coursesCompleted: 0), isEmpty);
    expect(
      evaluate(coursesCompleted: 1).map((b) => b.id),
      contains(BadgeId.firstCourse),
    );
  });

  test('3 Courses Completed only unlocks alongside First Course', () {
    final badges = evaluate(coursesCompleted: 3).map((b) => b.id).toSet();
    expect(badges, containsAll([BadgeId.firstCourse, BadgeId.threeCoursesCompleted]));
  });

  test('5 Courses Completed unlocks alongside the lower course tiers', () {
    final badges = evaluate(coursesCompleted: 5).map((b) => b.id).toSet();
    expect(
      badges,
      containsAll([
        BadgeId.firstCourse,
        BadgeId.threeCoursesCompleted,
        BadgeId.fiveCoursesCompleted,
      ]),
    );
  });

  test('streak badges use longest streak, not current streak, and unlock at their thresholds', () {
    expect(evaluate(longestStreak: 2).map((b) => b.id), isNot(contains(BadgeId.threeDayStreak)));
    expect(evaluate(longestStreak: 3).map((b) => b.id), contains(BadgeId.threeDayStreak));
    expect(evaluate(longestStreak: 6).map((b) => b.id), isNot(contains(BadgeId.sevenDayStreak)));
    expect(evaluate(longestStreak: 7).map((b) => b.id), contains(BadgeId.sevenDayStreak));
    expect(evaluate(longestStreak: 29).map((b) => b.id), isNot(contains(BadgeId.thirtyDayStreak)));
    expect(evaluate(longestStreak: 30).map((b) => b.id), contains(BadgeId.thirtyDayStreak));
    expect(evaluate(longestStreak: 99).map((b) => b.id), isNot(contains(BadgeId.hundredDayStreak)));
    expect(evaluate(longestStreak: 100).map((b) => b.id), contains(BadgeId.hundredDayStreak));
  });

  test('coding challenge badges unlock at their thresholds', () {
    expect(evaluate(codingChallengesAttempted: 24).map((b) => b.id), isEmpty);
    expect(
      evaluate(codingChallengesAttempted: 25).map((b) => b.id),
      contains(BadgeId.twentyFiveCodingChallenges),
    );
    expect(
      evaluate(codingChallengesAttempted: 100).map((b) => b.id),
      containsAll([
        BadgeId.twentyFiveCodingChallenges,
        BadgeId.hundredCodingChallenges,
      ]),
    );
  });

  test('lesson badges unlock at their thresholds', () {
    expect(evaluate(lessonsCompleted: 9).map((b) => b.id), isEmpty);
    expect(
      evaluate(lessonsCompleted: 50).map((b) => b.id),
      containsAll([BadgeId.tenLessonsCompleted, BadgeId.fiftyLessonsCompleted]),
    );
    expect(
      evaluate(lessonsCompleted: 200).map((b) => b.id),
      contains(BadgeId.twoHundredLessonsCompleted),
    );
  });

  test('experience level badges unlock cumulatively as the level rises', () {
    expect(
      evaluate(experienceLevel: ExperienceLevel.newDeveloper).map((b) => b.id),
      isEmpty,
    );
    expect(
      evaluate(experienceLevel: ExperienceLevel.beginnerDeveloper).map((b) => b.id),
      [BadgeId.beginnerDeveloperReached],
    );
    expect(
      evaluate(experienceLevel: ExperienceLevel.advancedDeveloper).map((b) => b.id),
      containsAll([
        BadgeId.beginnerDeveloperReached,
        BadgeId.juniorDeveloperReached,
        BadgeId.intermediateDeveloperReached,
        BadgeId.advancedDeveloperReached,
      ]),
    );
  });

  test('quiz badges unlock at their thresholds, independent of perfect scores', () {
    expect(evaluate(quizzesPassed: 0).map((b) => b.id), isEmpty);
    expect(
      evaluate(quizzesPassed: 1).map((b) => b.id),
      contains(BadgeId.firstQuizPassed),
    );
    expect(
      evaluate(quizzesPassed: 10).map((b) => b.id),
      containsAll([BadgeId.firstQuizPassed, BadgeId.tenQuizzesPassed]),
    );
  });

  test('perfect quiz badges unlock at their thresholds', () {
    expect(evaluate(perfectQuizzes: 0).map((b) => b.id), isEmpty);
    expect(
      evaluate(perfectQuizzes: 1).map((b) => b.id),
      contains(BadgeId.perfectQuiz),
    );
    expect(
      evaluate(perfectQuizzes: 5).map((b) => b.id),
      containsAll([BadgeId.perfectQuiz, BadgeId.fivePerfectQuizzes]),
    );
  });

  test('multiple categories can unlock at once', () {
    final badges = evaluate(
      coursesCompleted: 5,
      longestStreak: 40,
      codingChallengesAttempted: 200,
      lessonsCompleted: 60,
    );
    // courses: 3, streak: 4 (3/7/14/30, not 100), coding: 2, lessons: 2 (10/50, not 200)
    expect(badges.length, 11);
  });
}
