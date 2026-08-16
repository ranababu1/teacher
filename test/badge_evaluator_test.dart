import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/profile/domain/badge_evaluator.dart';
import 'package:teacher/features/profile/domain/models/badge.dart';

void main() {
  final evaluator = BadgeEvaluator();

  List<Badge> evaluate({
    int coursesCompleted = 0,
    int longestStreak = 0,
    int codingChallengesAttempted = 0,
    int lessonsCompleted = 0,
  }) => evaluator.evaluate(
    coursesCompleted: coursesCompleted,
    longestStreak: longestStreak,
    codingChallengesAttempted: codingChallengesAttempted,
    lessonsCompleted: lessonsCompleted,
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

  test('streak badges use longest streak, not current streak, and unlock at their thresholds', () {
    expect(evaluate(longestStreak: 6).map((b) => b.id), isNot(contains(BadgeId.sevenDayStreak)));
    expect(evaluate(longestStreak: 7).map((b) => b.id), contains(BadgeId.sevenDayStreak));
    expect(evaluate(longestStreak: 29).map((b) => b.id), isNot(contains(BadgeId.thirtyDayStreak)));
    expect(evaluate(longestStreak: 30).map((b) => b.id), contains(BadgeId.thirtyDayStreak));
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
  });

  test('multiple categories can unlock at once', () {
    final badges = evaluate(
      coursesCompleted: 5,
      longestStreak: 40,
      codingChallengesAttempted: 200,
      lessonsCompleted: 60,
    );
    expect(badges.length, 8);
  });
}
