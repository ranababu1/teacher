import '../../curriculum/domain/models/item_type.dart';
import '../../progress/domain/concept_mastery_repository.dart';
import '../../progress/domain/mastery_calculator.dart';
import '../../progress/domain/student_progress_repository.dart';
import '../../review/domain/review_schedule_repository.dart';
import '../../review/domain/review_scheduling_service.dart';
import 'attempts_repository.dart';
import 'models/attempt.dart';
import 'models/attempt_outcome.dart';

/// The single entry point every UI (lesson, practice, review) calls when a
/// learner submits a response. Coordinates four things that must always
/// stay in sync — see instructions.md section 57, which asks to keep these
/// concepts separate as *models* while still evolving together as facts
/// about the same event:
///
/// 1. Persist the raw attempt (evidence).
/// 2. Recompute concept mastery from that evidence.
/// 3. Reschedule the next review based on how it went.
/// 4. For assessments, mark the concept's lesson as completed.
class RecordAttemptUseCase {
  RecordAttemptUseCase({
    required AttemptsRepository attemptsRepository,
    required ConceptMasteryRepository masteryRepository,
    required ReviewScheduleRepository reviewScheduleRepository,
    required StudentProgressRepository studentProgressRepository,
    MasteryCalculator? masteryCalculator,
    ReviewSchedulingService? reviewSchedulingService,
  }) : _attemptsRepository = attemptsRepository,
       _masteryRepository = masteryRepository,
       _reviewScheduleRepository = reviewScheduleRepository,
       _studentProgressRepository = studentProgressRepository,
       _masteryCalculator = masteryCalculator ?? MasteryCalculator(),
       _reviewSchedulingService =
           reviewSchedulingService ?? const ReviewSchedulingService();

  final AttemptsRepository _attemptsRepository;
  final ConceptMasteryRepository _masteryRepository;
  final ReviewScheduleRepository _reviewScheduleRepository;
  final StudentProgressRepository _studentProgressRepository;
  final MasteryCalculator _masteryCalculator;
  final ReviewSchedulingService _reviewSchedulingService;

  Future<Attempt> call({
    required String conceptId,
    required String itemId,
    required ItemKind itemKind,
    required ItemType itemType,
    required AttemptOutcome outcome,
  }) async {
    final attempt = await _attemptsRepository.saveAttempt(
      conceptId: conceptId,
      itemId: itemId,
      itemKind: itemKind,
      itemType: itemType,
      outcome: outcome,
    );

    final previousSchedule = await _reviewScheduleRepository.getSchedule(
      conceptId,
    );
    final nextSchedule = _reviewSchedulingService.scheduleNext(
      current: previousSchedule,
      performance: outcome.performanceBucket,
    );
    await _reviewScheduleRepository.saveSchedule(nextSchedule);

    final previousMastery = await _masteryRepository.getMastery(conceptId);
    final nextMastery = _masteryCalculator.recompute(
      current: previousMastery,
      itemType: itemType,
      outcome: outcome,
      isOverdueForReview: nextSchedule.dueAt.isBefore(DateTime.now()),
    );
    await _masteryRepository.saveMastery(
      nextMastery.copyWith(
        lastReviewedAt: nextSchedule.lastReviewedAt,
        nextReviewAt: nextSchedule.dueAt,
      ),
    );

    if (itemKind == ItemKind.assessment) {
      await _studentProgressRepository.markCompleted(conceptId);
    }

    return attempt;
  }
}
