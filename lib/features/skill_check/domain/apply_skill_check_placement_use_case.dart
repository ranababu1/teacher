import '../../progress/domain/learning_path_progress_repository.dart';
import '../../progress/domain/module_test_progress_repository.dart';
import 'models/skill_check.dart';

/// Applies a skill check's placement: starts the course (if needed) and
/// records each tested-out topic as passed, which unlocks the recommended
/// starting topic under the normal topic-test gate.
class ApplySkillCheckPlacementUseCase {
  ApplySkillCheckPlacementUseCase({
    required LearningPathProgressRepository pathProgress,
    required ModuleTestProgressRepository moduleTests,
  }) : _pathProgress = pathProgress,
       _moduleTests = moduleTests;

  final LearningPathProgressRepository _pathProgress;
  final ModuleTestProgressRepository _moduleTests;

  Future<void> call(SkillCheckResult result) async {
    if (!await _pathProgress.isPathStarted(result.learningPathId)) {
      await _pathProgress.markPathStarted(result.learningPathId);
    }
    for (final moduleId in result.testedOutModuleIds) {
      final score = result.topicScores.firstWhere(
        (t) => t.module.id == moduleId,
      );
      await _moduleTests.markModulePassed(
        learningPathId: result.learningPathId,
        moduleId: moduleId,
        scorePercent: 100,
        questionCount: score.total,
      );
    }
  }
}
