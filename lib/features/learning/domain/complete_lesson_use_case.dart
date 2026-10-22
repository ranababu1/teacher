import '../../progress/domain/student_progress_repository.dart';
import 'lesson_resume_repository.dart';

/// Finishing the last step: marks the concept completed with the existing
/// progress logic and forgets the resume point so the next visit starts
/// from the beginning.
class CompleteLessonUseCase {
  const CompleteLessonUseCase({
    required this.progressRepository,
    required this.resumeRepository,
  });

  final StudentProgressRepository progressRepository;
  final LessonResumeRepository resumeRepository;

  Future<void> call(String conceptId) async {
    await progressRepository.markCompleted(conceptId);
    await resumeRepository.clear(conceptId);
  }
}
