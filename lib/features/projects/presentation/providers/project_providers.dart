import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../data/project_repository_impl.dart';
import '../../domain/models/project.dart';
import '../../domain/models/project_overview.dart';
import '../../domain/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepositoryImpl(rootBundle),
);

final projectProgressRepositoryProvider = Provider<ProjectProgressRepository>(
  (ref) => ProjectProgressRepositoryImpl(ref.watch(appDatabaseProvider)),
);

Future<ProjectOverview?> _overview(Ref ref, Project project) async {
  final path = await ref.watch(
    learningPathProvider(project.learningPathId).future,
  );
  if (path == null) return null;
  final completed = await ref
      .watch(projectProgressRepositoryProvider)
      .getCompletedMilestones(project.id);
  final recommendedId = project.recommendedAfterModuleId;
  final topic = recommendedId == null
      ? null
      : path.modules.where((m) => m.id == recommendedId).firstOrNull;
  final passed = topic == null
      ? true
      : (await ref.watch(
          passedModuleIdsProvider(project.learningPathId).future,
        )).contains(topic.id);
  return ProjectOverview(
    project: project,
    courseTitle: path.title,
    completedMilestoneIds: completed,
    recommendedTopicTitle: topic?.title,
    isRecommendedTopicPassed: passed,
  );
}

/// Every project whose course exists, in-progress first, then ready ones,
/// then the rest; completed projects go last.
final projectOverviewsProvider = FutureProvider<List<ProjectOverview>>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final projects = await ref.watch(projectRepositoryProvider).getProjects();
  final overviews = <ProjectOverview>[];
  for (final p in projects) {
    final o = await _overview(ref, p);
    if (o != null) overviews.add(o);
  }
  int rank(ProjectOverview o) {
    if (o.isComplete) return 3;
    if (o.isStarted) return 0;
    return o.isRecommendedTopicPassed ? 1 : 2;
  }

  final indexed = overviews.asMap().entries.toList()
    ..sort((a, b) {
      final r = rank(a.value).compareTo(rank(b.value));
      return r != 0 ? r : a.key.compareTo(b.key);
    });
  return [for (final e in indexed) e.value];
});

final projectOverviewProvider = FutureProvider.family<ProjectOverview?, String>(
  (ref, projectId) async {
    ref.watch(dataRevisionProvider);
    final project = await ref
        .watch(projectRepositoryProvider)
        .getProject(projectId);
    if (project == null) return null;
    return _overview(ref, project);
  },
);

/// Ticks or unticks a milestone and refreshes progress readers.
class ProjectMilestoneToggler {
  ProjectMilestoneToggler(this._ref);

  final Ref _ref;

  Future<void> call({
    required String projectId,
    required String milestoneId,
    required bool completed,
  }) async {
    await _ref
        .read(projectProgressRepositoryProvider)
        .setMilestoneCompleted(
          projectId: projectId,
          milestoneId: milestoneId,
          completed: completed,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final projectMilestoneTogglerProvider = Provider<ProjectMilestoneToggler>(
  ProjectMilestoneToggler.new,
);
