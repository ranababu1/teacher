/// Remembers the last step a learner viewed in each lesson so it can be
/// reopened there.
abstract class LessonResumeRepository {
  Future<String?> lastStepId(String conceptId);

  Future<void> saveStep(String conceptId, String stepId);

  Future<void> clear(String conceptId);
}
