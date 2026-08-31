import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../data/concept_mastery_repository_impl.dart';
import '../../data/learning_path_progress_repository_impl.dart';
import '../../data/module_test_progress_repository_impl.dart';
import '../../data/student_progress_repository_impl.dart';
import '../../domain/concept_mastery_repository.dart';
import '../../domain/learning_path_progress_repository.dart';
import '../../domain/models/concept_mastery.dart';
import '../../domain/models/mastery_status.dart';
import '../../domain/models/path_progress_summary.dart';
import '../../domain/models/student_progress.dart';
import '../../domain/module_test_progress_repository.dart';
import '../../domain/student_progress_repository.dart';

final conceptMasteryRepositoryProvider = Provider<ConceptMasteryRepository>((
  ref,
) {
  return ConceptMasteryRepositoryImpl(ref.watch(appDatabaseProvider));
});

final studentProgressRepositoryProvider = Provider<StudentProgressRepository>((
  ref,
) {
  return StudentProgressRepositoryImpl(ref.watch(appDatabaseProvider));
});

final learningPathProgressRepositoryProvider =
    Provider<LearningPathProgressRepository>((ref) {
      return LearningPathProgressRepositoryImpl(ref.watch(appDatabaseProvider));
    });

final moduleTestProgressRepositoryProvider =
    Provider<ModuleTestProgressRepository>((ref) {
      return ModuleTestProgressRepositoryImpl(ref.watch(appDatabaseProvider));
    });

final allMasteryProvider = FutureProvider<List<ConceptMastery>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(conceptMasteryRepositoryProvider).getAllMastery();
});

final masteryForConceptProvider = FutureProvider.family<ConceptMastery, String>(
  (ref, conceptId) {
    ref.watch(dataRevisionProvider);
    return ref.watch(conceptMasteryRepositoryProvider).getMastery(conceptId);
  },
);

final allStudentProgressProvider = FutureProvider<List<StudentProgress>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(studentProgressRepositoryProvider).getAllProgress();
});

/// Learning path ids the learner has explicitly Started — the hard gate
/// that must be satisfied before any of that path's lessons can be opened.
final startedLearningPathIdsProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(learningPathProgressRepositoryProvider).getStartedPathIds();
});

final isLearningPathStartedProvider = FutureProvider.family<bool, String>((
  ref,
  pathId,
) async {
  final started = await ref.watch(startedLearningPathIdsProvider.future);
  return started.contains(pathId);
});

/// The entry point UI should call to Start a course — wraps the plain
/// repository write with telling dependent read providers to refetch, the
/// same shape as `AttemptRecorder` in assessment_providers.dart.
final learningPathStarterProvider = Provider<LearningPathStarter>((ref) {
  return LearningPathStarter(ref);
});

class LearningPathStarter {
  LearningPathStarter(this._ref);

  final Ref _ref;

  Future<void> call(String learningPathId) async {
    await _ref
        .read(learningPathProgressRepositoryProvider)
        .markPathStarted(learningPathId);
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

/// Module ("topic") ids within [learningPathId] whose gating test has
/// been passed — see [ModuleTestProgressRepository].
final passedModuleIdsProvider = FutureProvider.family<Set<String>, String>((
  ref,
  learningPathId,
) {
  ref.watch(dataRevisionProvider);
  return ref
      .watch(moduleTestProgressRepositoryProvider)
      .getPassedModuleIds(learningPathId);
});

/// Total count of passed module tests ("quizzes") across every learning
/// path — feeds the Profile screen's XP total.
final allPassedModuleTestCountProvider = FutureProvider<int>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(moduleTestProgressRepositoryProvider).getPassedModuleCount();
});

/// The entry point UI should call once a learner passes a module's topic
/// test — wraps the plain repository write with telling dependent read
/// providers to refetch, the same shape as [LearningPathStarter].
final moduleTestRecorderProvider = Provider<ModuleTestRecorder>((ref) {
  return ModuleTestRecorder(ref);
});

class ModuleTestRecorder {
  ModuleTestRecorder(this._ref);

  final Ref _ref;

  Future<void> call({
    required String learningPathId,
    required String moduleId,
    required int scorePercent,
    required int questionCount,
  }) async {
    await _ref.read(moduleTestProgressRepositoryProvider).markModulePassed(
      learningPathId: learningPathId,
      moduleId: moduleId,
      scorePercent: scorePercent,
      questionCount: questionCount,
    );
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

/// Aggregated per-path progress, combining curriculum structure with
/// persisted mastery. Concepts with no mastery row yet are `notStarted`.
final pathProgressSummariesProvider = FutureProvider<List<PathProgressSummary>>(
  (ref) async {
    final paths = await ref.watch(learningPathsProvider.future);
    final masteryList = await ref.watch(allMasteryProvider.future);
    final masteryByConceptId = {for (final m in masteryList) m.conceptId: m};

    return paths.map((path) {
      final counts = <MasteryStatus, int>{};
      var totalMastery = 0.0;

      for (final concept in path.allConcepts) {
        final mastery = masteryByConceptId[concept.id];
        final status = mastery?.status ?? MasteryStatus.notStarted;
        counts[status] = (counts[status] ?? 0) + 1;
        totalMastery += mastery?.overallMastery ?? 0;
      }

      final total = path.allConcepts.length;
      return PathProgressSummary(
        learningPathId: path.id,
        title: path.title,
        totalConcepts: total,
        overallPercent: total == 0 ? 0 : totalMastery / total,
        statusCounts: counts,
      );
    }).toList();
  },
);

/// [pathProgressSummariesProvider] filtered to paths the learner has
/// explicitly Started — feeds the Dashboard's Learning Progress section
/// and the standalone Progress screen. The Learning Paths catalog screen
/// intentionally stays on the unfiltered provider above.
final startedPathProgressSummariesProvider =
    FutureProvider<List<PathProgressSummary>>((ref) async {
      final summaries = await ref.watch(pathProgressSummariesProvider.future);
      final startedIds = await ref.watch(startedLearningPathIdsProvider.future);
      return summaries
          .where((s) => startedIds.contains(s.learningPathId))
          .toList();
    });
