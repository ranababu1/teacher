import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../data/concept_mastery_repository_impl.dart';
import '../../data/student_progress_repository_impl.dart';
import '../../domain/concept_mastery_repository.dart';
import '../../domain/models/concept_mastery.dart';
import '../../domain/models/mastery_status.dart';
import '../../domain/models/path_progress_summary.dart';
import '../../domain/models/student_progress.dart';
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
