import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../progress/domain/models/student_progress.dart';
import 'models/continue_learning_state.dart';

/// Resolves the Dashboard's "Continue Learning" card. See
/// instructions.md section 8.
class ContinueLearningService {
  ContinueLearningState resolve({
    required List<StudentProgress> allProgress,
    required List<LearningPath> paths,
  }) {
    if (allProgress.isEmpty) return const ContinueLearningEmpty();

    final conceptsById = <String, Concept>{
      for (final path in paths)
        for (final c in path.allConcepts) c.id: c,
    };
    final pathsById = {for (final p in paths) p.id: p};
    final progressByConceptId = {
      for (final p in allProgress) p.conceptId: p,
    };

    final sorted = [...allProgress]
      ..sort((a, b) {
        final aTime = a.lastAccessedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastAccessedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    // Skip progress rows whose concept no longer exists in the current
    // curriculum bundle (a content update between versions could leave a
    // stale conceptId behind) rather than crashing or reporting "empty"
    // for a learner who has real progress elsewhere.
    StudentProgress? mostRecent;
    Concept? mostRecentConcept;
    for (final candidate in sorted) {
      final concept = conceptsById[candidate.conceptId];
      if (concept != null) {
        mostRecent = candidate;
        mostRecentConcept = concept;
        break;
      }
    }
    if (mostRecent == null || mostRecentConcept == null) {
      return const ContinueLearningEmpty();
    }

    if (!mostRecent.isCompleted) {
      return ContinueLearningConcept(mostRecentConcept);
    }

    final path = pathsById[mostRecentConcept.learningPathId];
    if (path == null) return const ContinueLearningEmpty();

    // Scan the whole path (not just forward from the most-recent concept)
    // so a learner who jumped around and left an earlier concept
    // incomplete gets sent to the actual gap, not falsely told the path
    // is complete.
    for (final concept in path.allConcepts) {
      final progress = progressByConceptId[concept.id];
      if (progress == null || !progress.isCompleted) {
        return ContinueLearningConcept(concept);
      }
    }

    return ContinueLearningPathCompleted(pathId: path.id, pathTitle: path.title);
  }
}
