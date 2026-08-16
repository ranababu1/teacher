import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/student_progress.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/continue_learning_service.dart';
import '../../domain/models/continue_learning_state.dart';
import '../../domain/models/dashboard_recommendation.dart';
import '../../domain/recommendation_service.dart';

/// Drives the "Continue Learning" card. See instructions.md section 8.
final continueLearningProvider = FutureProvider<ContinueLearningState>((
  ref,
) async {
  final allProgress = await ref.watch(allStudentProgressProvider.future);
  final paths = await ref.watch(learningPathsProvider.future);
  final startedPathIds = await ref.watch(startedLearningPathIdsProvider.future);
  return ContinueLearningService().resolve(
    allProgress: allProgress,
    paths: paths,
    startedPathIds: startedPathIds,
  );
});

final dashboardRecommendationProvider =
    FutureProvider<DashboardRecommendation?>((ref) async {
      final allPaths = await ref.watch(learningPathsProvider.future);
      final startedIds = await ref.watch(startedLearningPathIdsProvider.future);
      final paths = allPaths.where((p) => startedIds.contains(p.id)).toList();
      final masteryList = await ref.watch(allMasteryProvider.future);
      final masteryByConceptId = {for (final m in masteryList) m.conceptId: m};

      return RecommendationService().recommendNext(
        paths: paths,
        masteryByConceptId: masteryByConceptId,
      );
    });

/// Concepts completed most recently, for the Recent Activity section.
final recentlyCompletedProvider = FutureProvider<List<StudentProgress>>((
  ref,
) async {
  final allProgress = await ref.watch(allStudentProgressProvider.future);
  final completed = allProgress.where((p) => p.isCompleted).toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  return completed.take(5).toList();
});
