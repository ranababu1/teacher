abstract class ModuleTestProgressRepository {
  /// The ids of every module within [learningPathId] whose topic test has
  /// been passed (including grandfathered rows from before the gate
  /// existed).
  Future<Set<String>> getPassedModuleIds(String learningPathId);

  Future<bool> isModulePassed(String learningPathId, String moduleId);

  /// Total count of passed module tests ("quizzes") across every learning
  /// path — feeds XP, not scoped to a single path like [getPassedModuleIds].
  Future<int> getPassedModuleCount();

  /// Records a passed attempt for (learningPathId, moduleId). Idempotent
  /// — a module already passed keeps its original `passedAt`/score.
  Future<void> markModulePassed({
    required String learningPathId,
    required String moduleId,
    required int scorePercent,
    required int questionCount,
  });
}
