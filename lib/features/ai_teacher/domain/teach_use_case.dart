import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import '../../curriculum/domain/curriculum_repository.dart';
import '../../progress/domain/concept_mastery_repository.dart';
import '../../progress/domain/models/concept_mastery.dart';
import '../../progress/domain/models/mastery_status.dart';
import 'ai_provider.dart';
import 'misconception_repository.dart';
import 'models/teacher_response.dart';
import 'models/teaching_context.dart';

/// Assembles a [TeachingContext] from the curriculum, mastery, and
/// misconception repositories, then asks the [AIProvider] to respond —
/// see instructions.md section 20: never send an isolated question to the
/// AI if context is available. Plain Dart, no Riverpod, so it's trivially
/// unit-testable with a fake [AIProvider] (mirrors [RecordAttemptUseCase]).
class TeachUseCase {
  TeachUseCase({
    required CurriculumRepository curriculumRepository,
    required ConceptMasteryRepository masteryRepository,
    required MisconceptionRepository misconceptionRepository,
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
  }) : _curriculumRepository = curriculumRepository,
       _masteryRepository = masteryRepository,
       _misconceptionRepository = misconceptionRepository,
       _aiProvider = aiProvider;

  final CurriculumRepository _curriculumRepository;
  final ConceptMasteryRepository _masteryRepository;
  final MisconceptionRepository _misconceptionRepository;
  final AIProvider _aiProvider;

  /// When true, logs request metadata (concept id, capability) — never the
  /// prompt content or API key. See instructions.md section 38.
  final bool requestLoggingEnabled;

  Future<TeacherResponse> call({
    required String conceptId,
    String? learnerMessage,
  }) async {
    final concept = await _curriculumRepository.getConcept(conceptId);
    if (concept == null) {
      throw ContentNotFoundException('No concept found for id $conceptId');
    }

    final prerequisites = await _curriculumRepository.getPrerequisiteConcepts(
      conceptId,
    );
    final mastery = await _masteryRepository.getMastery(conceptId);
    final unresolved = await _misconceptionRepository.getUnresolvedForConcept(
      conceptId,
    );

    final context = TeachingContext(
      concept: concept,
      prerequisites: prerequisites,
      mastery: mastery,
      recentMisconceptions: unresolved.map((m) => m.description).toList(),
      currentDifficultyLevel: _difficultyLevelFor(mastery),
    );

    if (requestLoggingEnabled) {
      AppLogger.debug(
        'AI teach request: conceptId=$conceptId hasLearnerMessage=${learnerMessage != null}',
      );
    }

    return _aiProvider.teach(
      TeacherRequest(context: context, learnerMessage: learnerMessage),
    );
  }

  /// A coarse 1-7 mapping (see instructions.md section 17's difficulty
  /// ladder) from mastery status, used to calibrate the AI's response —
  /// deliberately simple, not a full adaptive-difficulty engine.
  int _difficultyLevelFor(ConceptMastery mastery) => switch (mastery.status) {
    MasteryStatus.notStarted => 1,
    MasteryStatus.learning => 2,
    MasteryStatus.developing => 3,
    MasteryStatus.needsReview => 3,
    MasteryStatus.proficient => 5,
    MasteryStatus.mastered => 6,
  };
}
