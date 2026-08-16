import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/models/attempt.dart';
import 'assessment_providers.dart';

/// Concepts (in started paths) that have at least one assessment but no
/// recorded assessment attempt yet — feeds the Dashboard's "Pending
/// tests" card.
///
/// Deliberately computed from attempts directly rather than
/// `StudentProgress.isCompleted` — today an assessment attempt happens to
/// also mark a concept complete, but coupling "pending" to that side
/// effect would silently break if that completion rule ever changes.
final pendingTestsProvider = FutureProvider<List<Concept>>((ref) async {
  final paths = await ref.watch(learningPathsProvider.future);
  final startedIds = await ref.watch(startedLearningPathIdsProvider.future);
  final allAttempts = await ref.watch(allAttemptsProvider.future);

  final attemptedConceptIds = {
    for (final a in allAttempts)
      if (a.itemKind == ItemKind.assessment) a.conceptId,
  };

  return paths
      .where((p) => startedIds.contains(p.id))
      .expand((p) => p.allConcepts)
      .where(
        (c) => c.assessments.isNotEmpty && !attemptedConceptIds.contains(c.id),
      )
      .toList();
});
