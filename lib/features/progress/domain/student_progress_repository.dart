import 'models/student_progress.dart';

abstract class StudentProgressRepository {
  Future<StudentProgress?> getProgress(String conceptId);

  Future<List<StudentProgress>> getAllProgress();

  /// Marks a concept as opened. Sets `startedAt` the first time only.
  Future<void> markStarted({
    required String conceptId,
    required String learningPathId,
    required String moduleId,
  });

  Future<void> markCompleted(String conceptId);
}
