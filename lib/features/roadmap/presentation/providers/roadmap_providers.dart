import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../ai_teacher/presentation/providers/teach_providers.dart';
import '../../../coding_challenges/presentation/providers/coding_challenge_providers.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../system_design/presentation/providers/system_design_providers.dart';
import '../../data/roadmap_repository_impl.dart';
import '../../domain/generate_roadmap_use_case.dart';
import '../../domain/models/roadmap.dart';
import '../../domain/models/roadmap_catalog.dart';
import '../../domain/roadmap_catalog_builder.dart';
import '../../domain/roadmap_progress.dart';
import '../../domain/roadmap_repository.dart';

final roadmapRepositoryProvider = Provider<RoadmapRepository>(
  (ref) => RoadmapRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final generateRoadmapUseCaseProvider = Provider<GenerateRoadmapUseCase>(
  (ref) => GenerateRoadmapUseCase(aiProvider: ref.watch(aiProviderProvider)),
);

/// Every topic, project, design exercise and long-form challenge a roadmap
/// may use, with rough hours.
final roadmapCatalogProvider = FutureProvider<RoadmapCatalog>((ref) async {
  final paths = await ref.watch(learningPathsProvider.future);
  final projects = await ref.watch(projectRepositoryProvider).getProjects();
  final design = await ref.watch(systemDesignListProvider.future);
  final challenges = await ref.watch(codingChallengeListProvider.future);
  return const RoadmapCatalogBuilder().build(
    paths: paths,
    projects: projects,
    systemDesign: [for (final d in design) d.exercise],
    challenges: [for (final c in challenges) c.challenge],
  );
});

/// What is already done, from existing progress data (topic tests passed,
/// project milestones, design and challenge records).
final roadmapCompletionProvider = FutureProvider<RoadmapCompletion>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final paths = await ref.watch(learningPathsProvider.future);
  final passed = <String>{};
  for (final p in paths) {
    final ids = await ref.watch(passedModuleIdsProvider(p.id).future);
    passed.addAll(ids.map((m) => '${p.id}/$m'));
  }
  final projects = await ref.watch(projectOverviewsProvider.future);
  final design = await ref.watch(systemDesignListProvider.future);
  final challenges = await ref.watch(codingChallengeListProvider.future);
  return RoadmapCompletion(
    passedTopicIds: passed,
    completedProjectIds: {
      for (final o in projects)
        if (o.isComplete) o.project.id,
    },
    finishedDesignIds: {
      for (final d in design)
        if (d.record != null) d.exercise.id,
    },
    finishedChallengeIds: {
      for (final c in challenges)
        if (c.record != null) c.challenge.id,
    },
  );
});

/// The saved roadmap (null when none) and the edits a learner can make.
class RoadmapController extends AsyncNotifier<Roadmap?> {
  @override
  Future<Roadmap?> build() => ref.watch(roadmapRepositoryProvider).load();

  /// Builds and saves a new roadmap, replacing the old one only on
  /// success. Errors are rethrown for the screen to show.
  Future<RoadmapGenerationResult> generate(
    RoadmapGoal goal, {
    required bool useAi,
  }) async {
    final catalog = await ref.read(roadmapCatalogProvider.future);
    final completion = await ref.read(roadmapCompletionProvider.future);
    final useCase = ref.read(generateRoadmapUseCaseProvider);
    final result = useAi
        ? await useCase.generate(
            goal: goal,
            catalog: catalog,
            completion: completion,
          )
        : RoadmapGenerationResult(
            roadmap: useCase.buildOffline(
              goal: goal,
              catalog: catalog,
              completion: completion,
            ),
          );
    await _save(result.roadmap);
    return result;
  }

  Future<void> removeItem(String key) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.removeItem(key));
  }

  Future<void> moveItem(String key, int delta) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _save(current.moveItem(key, delta));
  }

  Future<void> clear() async {
    await ref.read(roadmapRepositoryProvider).clear();
    state = const AsyncData(null);
  }

  Future<void> _save(Roadmap roadmap) async {
    await ref.read(roadmapRepositoryProvider).save(roadmap);
    state = AsyncData(roadmap);
  }
}

final roadmapControllerProvider =
    AsyncNotifierProvider<RoadmapController, Roadmap?>(RoadmapController.new);

/// Progress through the saved roadmap, or null when there is none.
final roadmapProgressProvider = FutureProvider<RoadmapProgress?>((ref) async {
  final roadmap = await ref.watch(roadmapControllerProvider.future);
  if (roadmap == null) return null;
  final completion = await ref.watch(roadmapCompletionProvider.future);
  return RoadmapProgress(roadmap, completion);
});
