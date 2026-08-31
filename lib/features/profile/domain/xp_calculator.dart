import '../../assessment/domain/attempt_quality.dart';
import '../../assessment/domain/models/attempt.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../progress/domain/models/student_progress.dart';
import '../../progress/domain/path_completion.dart';

/// Converts learning activity into XP, generously — every tier is bigger
/// than the last, matching the size of the achievement: opening the app,
/// completing a lesson, completing a whole topic, passing a topic's quiz,
/// and completing a course. Each item can still only ever award XP once
/// (via its first attempt, chronologically), and app opens only count
/// once per calendar day, so nothing here can be farmed by repeating an
/// action. See instructions.md sections 44-45.
class XpCalculator {
  static const _exerciseXp = 20;
  static const _exerciseBonusXp = 25;
  static const _assessmentXp = 40;
  static const _assessmentBonusXp = 50;
  static const _conceptCompletedXp = 250;
  static const _moduleCompletedXp = 400;
  static const _moduleTestPassedXp = 600;
  static const _courseCompletedXp = 2000;
  static const _appOpenXp = 25;
  static const _qualityBonusThreshold = 0.6;

  int calculate({
    required List<Attempt> attempts,
    required List<StudentProgress> allProgress,
    required List<LearningPath> paths,
    int passedModuleTestCount = 0,
    int appOpenDays = 0,
  }) {
    var xp = 0;

    final chronological = [...attempts]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final seenItems = <String>{};
    for (final attempt in chronological) {
      if (!seenItems.add('${attempt.conceptId}::${attempt.itemId}')) continue;

      final bonus = qualityOf(attempt) >= _qualityBonusThreshold;
      xp += switch (attempt.itemKind) {
        ItemKind.exercise => _exerciseXp + (bonus ? _exerciseBonusXp : 0),
        ItemKind.assessment =>
          _assessmentXp + (bonus ? _assessmentBonusXp : 0),
      };
    }

    xp += allProgress.where((p) => p.isCompleted).length * _conceptCompletedXp;

    final progressByConceptId = {for (final p in allProgress) p.conceptId: p};

    final topicsCompleted = paths
        .expand((p) => p.modules)
        .where((m) => isModuleCompleted(m, progressByConceptId))
        .length;
    xp += topicsCompleted * _moduleCompletedXp;

    xp +=
        paths.where((p) => isPathCompleted(p, progressByConceptId)).length *
        _courseCompletedXp;

    xp += passedModuleTestCount * _moduleTestPassedXp;
    xp += appOpenDays * _appOpenXp;

    return xp;
  }
}
