import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/item_type.dart';
import 'explanation_chunker.dart';
import 'lesson_step.dart';

/// Builds the ordered, deterministic list of lesson steps for a concept:
/// goals, explanation chunks (with quick checks between them), one step per
/// example, misconceptions, Try It, Check Your Understanding. Empty steps
/// are skipped.
class LessonStepBuilder {
  const LessonStepBuilder({this.chunksPerCheck = 2});

  /// A quick check is offered after every [chunksPerCheck] explanation
  /// chunks (never after the last one), while questions remain.
  final int chunksPerCheck;

  List<LessonStep> build(
    Concept concept, {
    bool hasDetectedMisconceptions = false,
  }) {
    final steps = <LessonStep>[];
    final hasPrereqs = concept.prerequisites.isNotEmpty;
    if (concept.learningObjectives.isNotEmpty || hasPrereqs) {
      steps.add(
        GoalsStep(
          objectives: concept.learningObjectives,
          hasPrerequisites: hasPrereqs,
        ),
      );
    }

    final chunks = chunkExplanation(concept.explanation.sections);
    final checks = quickChecksFor(concept);
    var nextCheck = 0;
    for (final (i, chunk) in chunks.indexed) {
      steps.add(
        ExplanationStep(
          index: i,
          heading: chunk.heading,
          body: chunk.body,
          part: chunk.part,
          partCount: chunk.partCount,
        ),
      );
      final isLast = i == chunks.length - 1;
      if (!isLast &&
          (i + 1) % chunksPerCheck == 0 &&
          nextCheck < checks.length) {
        steps.add(QuickCheckStep(index: nextCheck, check: checks[nextCheck]));
        nextCheck++;
      }
    }

    for (final (i, example) in concept.examples.indexed) {
      steps.add(
        ExampleStep(index: i, count: concept.examples.length, example: example),
      );
    }
    if (concept.misconceptions.isNotEmpty || hasDetectedMisconceptions) {
      steps.add(MisconceptionsStep(misconceptions: concept.misconceptions));
    }
    if (concept.exercises.isNotEmpty) {
      steps.add(TryItStep(exercises: concept.exercises));
    }
    if (concept.assessments.isNotEmpty) {
      steps.add(CheckUnderstandingStep(assessments: concept.assessments));
    }
    return steps;
  }

  /// Quick checks drawn only from the concept's own data, in content order:
  /// each misconception becomes a true/false statement (the answer is
  /// always False, the clarification is the feedback), followed by the
  /// well-formed multiple-choice assessments. Nothing is invented.
  static List<QuickCheck> quickChecksFor(Concept concept) {
    return [
      for (final m in concept.misconceptions)
        if (m.description.trim().isNotEmpty)
          QuickCheck(
            prompt: 'True or false? ${m.description.trim()}',
            options: const ['True', 'False'],
            correctIndex: 1,
            feedback: m.clarification,
          ),
      for (final a in concept.assessments)
        if (a.type == ItemType.multipleChoice &&
            (a.options?.length ?? 0) >= 2 &&
            a.correctOptionIndex != null &&
            a.correctOptionIndex! >= 0 &&
            a.correctOptionIndex! < a.options!.length)
          QuickCheck(
            prompt: a.prompt,
            options: a.options!,
            correctIndex: a.correctOptionIndex!,
            feedback: a.explanation ?? '',
          ),
    ];
  }
}
