import 'package:equatable/equatable.dart';

import 'badge.dart';
import 'experience_level.dart';

/// Everything the Profile screen needs to render streak/XP/badges/stats,
/// composed in one place by [ProfileStatsService].
class LearnerStats extends Equatable {
  const LearnerStats({
    required this.coursesCompleted,
    required this.lessonsCompleted,
    required this.practiceQuestionsAttempted,
    required this.codingChallengesAttempted,
    required this.currentStreak,
    required this.totalXp,
    required this.experienceLevel,
    required this.badges,
  });

  final int coursesCompleted;
  final int lessonsCompleted;
  final int practiceQuestionsAttempted;
  final int codingChallengesAttempted;
  final int currentStreak;
  final int totalXp;
  final ExperienceLevel experienceLevel;
  final List<Badge> badges;

  static const empty = LearnerStats(
    coursesCompleted: 0,
    lessonsCompleted: 0,
    practiceQuestionsAttempted: 0,
    codingChallengesAttempted: 0,
    currentStreak: 0,
    totalXp: 0,
    experienceLevel: ExperienceLevel.newDeveloper,
    badges: [],
  );

  @override
  List<Object?> get props => [
    coursesCompleted,
    lessonsCompleted,
    practiceQuestionsAttempted,
    codingChallengesAttempted,
    currentStreak,
    totalXp,
    experienceLevel,
    badges,
  ];
}
