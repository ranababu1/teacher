import 'models/concept.dart';
import 'models/learning_path.dart';

abstract class CurriculumRepository {
  Future<List<LearningPath>> getLearningPaths();

  Future<LearningPath?> getLearningPath(String learningPathId);

  Future<Concept?> getConcept(String conceptId);

  /// Resolves a concept's `prerequisites` (IDs) into full [Concept]s.
  /// Prerequisite IDs that can't be found are silently skipped.
  Future<List<Concept>> getPrerequisiteConcepts(String conceptId);
}
