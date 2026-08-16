import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

/// The learning path currently selected in the Practice screen's course
/// dropdown. `null` means "not yet chosen" — the screen falls back to the
/// first available course without writing back to this provider.
final selectedPracticePathIdProvider = StateProvider<String?>((ref) => null);

/// Concepts with at least one exercise that the learner hasn't mastered
/// yet, across every started course — drives the Dashboard's practice
/// queue card. Intersected with "not mastered" (rather than just
/// "practicable") so the count can reach zero and the card can self-hide,
/// the same way the review queue does.
final practiceQueueProvider = FutureProvider<List<Concept>>((ref) async {
  final paths = await ref.watch(learningPathsProvider.future);
  final startedIds = await ref.watch(startedLearningPathIdsProvider.future);
  final mastery = await ref.watch(allMasteryProvider.future);
  final masteryByConceptId = {for (final m in mastery) m.conceptId: m};

  return paths
      .where((p) => startedIds.contains(p.id))
      .expand((p) => p.allConcepts)
      .where((c) => c.exercises.isNotEmpty)
      .where(
        (c) => masteryByConceptId[c.id]?.status != MasteryStatus.mastered,
      )
      .toList();
});
