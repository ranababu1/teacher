abstract class LearningPathProgressRepository {
  Future<Set<String>> getStartedPathIds();

  Future<bool> isPathStarted(String learningPathId);

  /// Marks [learningPathId] as started. Idempotent — a path already
  /// started keeps its original `startedAt`.
  Future<void> markPathStarted(String learningPathId);
}
