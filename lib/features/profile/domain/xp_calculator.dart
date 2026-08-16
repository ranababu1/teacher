import '../../assessment/domain/attempt_quality.dart';
import '../../assessment/domain/models/attempt.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../progress/domain/models/student_progress.dart';
import '../../progress/domain/path_completion.dart';

/// Converts genuine learning activity into XP. Every award ties to an
/// actual outcome — never to app-opens or elapsed time — and each item can
/// only ever award XP once (via its first attempt, chronologically), so
/// resubmitting an already-solved item can't be farmed for more points.
/// See instructions.md sections 44-45.
class XpCalculator {
  static const _exerciseXp = 10;
  static const _exerciseBonusXp = 15;
  static const _assessmentXp = 20;
  static const _assessmentBonusXp = 30;
  static const _conceptCompletedXp = 100;
  static const _courseCompletedXp = 500;
  static const _qualityBonusThreshold = 0.6;

  int calculate({
    required List<Attempt> attempts,
    required List<StudentProgress> allProgress,
    required List<LearningPath> paths,
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
    xp +=
        paths.where((p) => isPathCompleted(p, progressByConceptId)).length *
        _courseCompletedXp;

    return xp;
  }
}
