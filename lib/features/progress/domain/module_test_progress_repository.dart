abstract class ModuleTestProgressRepository {
  /// The ids of every module within [learningPathId] whose topic test has
  /// been passed (including grandfathered rows from before the gate
  /// existed).
  Future<Set<String>> getPassedModuleIds(String learningPathId);

  Future<bool> isModulePassed(String learningPathId, String moduleId);

  /// Total count of passed module tests ("quizzes") across every learning
  /// path — feeds XP, not scoped to a single path like [getPassedModuleIds].
  Future<int> getPassedModuleCount();

  /// `scorePercent` for every genuinely-passed module test, excluding
  /// grandfathered rows (backfilled for pre-gate progress, never a real
  /// attempt) — feeds quiz-related badges, where "passed a quiz" should
  /// mean an actual attempt happened.
  Future<List<int>> getPassedModuleScores();

  /// Same as [getPassedModuleScores], scoped to one learning path — feeds
  /// the Profile screen's per-course performance tier ("Passed" /
  /// "Expert" / "Legend").
  Future<List<int>> getPassedModuleScoresForPath(String learningPathId);

  /// Records a passed attempt for (learningPathId, moduleId). Idempotent
  /// — a module already passed keeps its original `passedAt`/score.
  Future<void> markModulePassed({
    required String learningPathId,
    required String moduleId,
    required int scorePercent,
    required int questionCount,
  });
}
