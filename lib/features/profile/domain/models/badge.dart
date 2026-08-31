import 'package:equatable/equatable.dart';

enum BadgeId {
  firstCourse,
  threeCoursesCompleted,
  fiveCoursesCompleted,
  threeDayStreak,
  sevenDayStreak,
  fourteenDayStreak,
  thirtyDayStreak,
  hundredDayStreak,
  beginnerDeveloperReached,
  juniorDeveloperReached,
  intermediateDeveloperReached,
  advancedDeveloperReached,
  tenLessonsCompleted,
  fiftyLessonsCompleted,
  twoHundredLessonsCompleted,
  twentyFiveCodingChallenges,
  hundredCodingChallenges,
  firstQuizPassed,
  tenQuizzesPassed,
  perfectQuiz,
  fivePerfectQuizzes,
}

/// A collectible unlocked by a monotonic milestone — see
/// [BadgeEvaluator]. Every criterion only ever increases, so a badge can
/// never be silently lost between two computations. [label] is the
/// flavorful collectible name (e.g. "On Fire"); [description] is the
/// concrete criterion it was earned for (e.g. "7 day streak"), shown as
/// a subtitle so the badge stays meaningful, not just decorative.
class Badge extends Equatable {
  const Badge({
    required this.id,
    required this.emoji,
    required this.label,
    required this.description,
  });

  final BadgeId id;
  final String emoji;
  final String label;
  final String description;

  @override
  List<Object?> get props => [id, emoji, label, description];
}
