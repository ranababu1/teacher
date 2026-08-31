import '../../assessment/domain/models/attempt.dart';
import '../../curriculum/domain/models/item_type.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../progress/domain/models/student_progress.dart';
import '../../progress/domain/path_completion.dart';
import 'badge_evaluator.dart';
import 'models/experience_level.dart';
import 'models/learner_stats.dart';
import 'streak_service.dart';
import 'xp_calculator.dart';

/// Composes streak/XP/badge/count data into one [LearnerStats] for the
/// Profile screen. See instructions.md section 45.
class ProfileStatsService {
  ProfileStatsService({
    StreakService? streakService,
    XpCalculator? xpCalculator,
    BadgeEvaluator? badgeEvaluator,
  }) : _streakService = streakService ?? StreakService(),
       _xpCalculator = xpCalculator ?? XpCalculator(),
       _badgeEvaluator = badgeEvaluator ?? BadgeEvaluator();

  final StreakService _streakService;
  final XpCalculator _xpCalculator;
  final BadgeEvaluator _badgeEvaluator;

  LearnerStats compute({
    required List<LearningPath> paths,
    required List<StudentProgress> allProgress,
    required List<Attempt> allAttempts,
    DateTime? now,
    int passedModuleTestCount = 0,
    int appOpenDays = 0,
  }) {
    final progressByConceptId = {for (final p in allProgress) p.conceptId: p};
    final coursesCompleted = paths
        .where((p) => isPathCompleted(p, progressByConceptId))
        .length;
    final lessonsCompleted = allProgress.where((p) => p.isCompleted).length;
    final practiceQuestionsAttempted = allAttempts
        .where((a) => a.itemKind == ItemKind.exercise)
        .length;
    // Not restricted to itemKind == exercise: Coding is a valid ItemType
    // for both exercises and assessments (mastery_calculator.dart switches
    // on itemType alone for the same reason), so this isn't a strict
    // subset of practiceQuestionsAttempted.
    final codingChallengesAttempted = allAttempts
        .where((a) => a.itemType == ItemType.coding)
        .length;

    final activeDays = <DateTime>{
      for (final p in allProgress)
        if (p.lastAccessedAt != null) dayOf(p.lastAccessedAt!),
      for (final a in allAttempts) dayOf(a.createdAt),
    };
    final currentStreak = _streakService.currentStreak(
      activeDays: activeDays,
      now: now,
    );
    final longestStreak = _streakService.longestStreak(activeDays: activeDays);

    final totalXp = _xpCalculator.calculate(
      attempts: allAttempts,
      allProgress: allProgress,
      paths: paths,
      passedModuleTestCount: passedModuleTestCount,
      appOpenDays: appOpenDays,
    );

    final badges = _badgeEvaluator.evaluate(
      coursesCompleted: coursesCompleted,
      longestStreak: longestStreak,
      codingChallengesAttempted: codingChallengesAttempted,
      lessonsCompleted: lessonsCompleted,
    );

    return LearnerStats(
      coursesCompleted: coursesCompleted,
      lessonsCompleted: lessonsCompleted,
      practiceQuestionsAttempted: practiceQuestionsAttempted,
      codingChallengesAttempted: codingChallengesAttempted,
      currentStreak: currentStreak,
      totalXp: totalXp,
      experienceLevel: ExperienceLevel.forXp(totalXp),
      badges: badges,
    );
  }
}
