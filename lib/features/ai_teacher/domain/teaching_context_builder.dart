import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/curriculum_repository.dart';
import '../../progress/domain/concept_mastery_repository.dart';
import '../../progress/domain/models/concept_mastery.dart';
import '../../progress/domain/models/mastery_status.dart';
import 'misconception_repository.dart';
import 'models/teaching_context.dart';

/// Assembles a [TeachingContext] from the curriculum, mastery, and
/// misconception repositories — the one place every AI Teacher use case
/// (teach/assess/evaluateExplanation) builds its context, so they can't
/// drift apart. See instructions.md section 20: never send an isolated
/// question to the AI if context is available.
class TeachingContextBuilder {
  TeachingContextBuilder({
    required CurriculumRepository curriculumRepository,
    required ConceptMasteryRepository masteryRepository,
    required MisconceptionRepository misconceptionRepository,
  }) : _curriculumRepository = curriculumRepository,
       _masteryRepository = masteryRepository,
       _misconceptionRepository = misconceptionRepository;

  final CurriculumRepository _curriculumRepository;
  final ConceptMasteryRepository _masteryRepository;
  final MisconceptionRepository _misconceptionRepository;

  Future<TeachingContext> build(String conceptId) async {
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

    return TeachingContext(
      concept: concept,
      prerequisites: prerequisites,
      mastery: mastery,
      recentMisconceptions: unresolved.map((m) => m.description).toList(),
      currentDifficultyLevel: _difficultyLevelFor(mastery),
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
