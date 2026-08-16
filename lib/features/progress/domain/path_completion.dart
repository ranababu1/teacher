import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/learning_path.dart';
import 'models/student_progress.dart';

/// The first concept in [path] (in curriculum order) that isn't yet
/// complete, or `null` if every concept is done. The single shared
/// definition of "is this path done" — used by both the Dashboard's
/// Continue Learning card and the Profile screen's course-completion
/// count, so the two can never silently disagree.
Concept? firstIncompleteConcept(
  LearningPath path,
  Map<String, StudentProgress> progressByConceptId,
) {
  for (final concept in path.allConcepts) {
    final progress = progressByConceptId[concept.id];
    if (progress == null || !progress.isCompleted) return concept;
  }
  return null;
}

bool isPathCompleted(
  LearningPath path,
  Map<String, StudentProgress> progressByConceptId,
) => firstIncompleteConcept(path, progressByConceptId) == null;
