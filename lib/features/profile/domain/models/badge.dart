import 'package:equatable/equatable.dart';

enum BadgeId {
  firstCourse,
  threeCoursesCompleted,
  sevenDayStreak,
  thirtyDayStreak,
  twentyFiveCodingChallenges,
  hundredCodingChallenges,
  tenLessonsCompleted,
  fiftyLessonsCompleted,
}

/// An achievement unlocked by a monotonic milestone — see
/// [BadgeEvaluator]. Every criterion only ever increases, so a badge can
/// never be silently lost between two computations.
class Badge extends Equatable {
  const Badge({required this.id, required this.emoji, required this.label});

  final BadgeId id;
  final String emoji;
  final String label;

  @override
  List<Object?> get props => [id, emoji, label];
}
