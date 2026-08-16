import '../../curriculum/domain/curriculum_repository.dart';
import '../../progress/domain/student_progress_repository.dart';
import 'models/flash_card.dart';

/// Builds this week's pool of flash cards from whatever concepts the
/// learner has actually opened in the last 7 days — never from AI
/// generation (keeps this fully offline-capable) and never from static
/// placeholder content (per instructions.md rule 12, nothing is shown
/// unless it was genuinely just learned).
///
/// One card per misconception (front: true/false prompt, back: the
/// clarification) plus one card from the concept's first explanation
/// section (front: a recall question, back: the section body) — capped
/// per concept so a single deeply-studied concept can't crowd out the
/// rest of the week's variety.
class GenerateWeeklyFlashcardsUseCase {
  GenerateWeeklyFlashcardsUseCase({
    required StudentProgressRepository progressRepository,
    required CurriculumRepository curriculumRepository,
  }) : _progressRepository = progressRepository,
       _curriculumRepository = curriculumRepository;

  static const _lookback = Duration(days: 7);
  static const _maxCardsPerConcept = 3;

  final StudentProgressRepository _progressRepository;
  final CurriculumRepository _curriculumRepository;

  Future<List<FlashCard>> call({DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(_lookback);

    final allProgress = await _progressRepository.getAllProgress();
    final recentConceptIds = allProgress
        .where(
          (p) => p.lastAccessedAt != null && p.lastAccessedAt!.isAfter(cutoff),
        )
        .map((p) => p.conceptId)
        .toList();

    final cards = <FlashCard>[];
    for (final conceptId in recentConceptIds) {
      final concept = await _curriculumRepository.getConcept(conceptId);
      if (concept == null) continue;

      var remaining = _maxCardsPerConcept;

      for (final misconception in concept.misconceptions) {
        if (remaining <= 0) break;
        cards.add(
          FlashCard(
            conceptId: concept.id,
            conceptTitle: concept.title,
            front:
                'True or false — about ${concept.title}:\n'
                '"${misconception.description}"',
            back: misconception.clarification,
          ),
        );
        remaining--;
      }

      if (remaining > 0 && concept.explanation.sections.isNotEmpty) {
        final section = concept.explanation.sections.first;
        cards.add(
          FlashCard(
            conceptId: concept.id,
            conceptTitle: concept.title,
            front: '${concept.title}: ${section.heading}?',
            back: section.body,
          ),
        );
      }
    }

    return cards;
  }
}
