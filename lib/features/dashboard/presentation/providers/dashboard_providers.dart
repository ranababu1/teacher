import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/student_progress.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/models/dashboard_recommendation.dart';
import '../../domain/recommendation_service.dart';

/// The concept the learner most recently opened, if any — drives the
/// "Continue Learning" card. See instructions.md section 8.
final continueLearningProvider = FutureProvider<Concept?>((ref) async {
  final allProgress = await ref.watch(allStudentProgressProvider.future);
  if (allProgress.isEmpty) return null;

  final sorted = [...allProgress]
    ..sort((a, b) {
      final aTime = a.lastAccessedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastAccessedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

  final mostRecent = sorted.first;
  return ref
      .watch(curriculumRepositoryProvider)
      .getConcept(mostRecent.conceptId);
});

final dashboardRecommendationProvider =
    FutureProvider<DashboardRecommendation?>((ref) async {
      final paths = await ref.watch(learningPathsProvider.future);
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
