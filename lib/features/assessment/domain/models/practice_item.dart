import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/assessment.dart';
import '../../../curriculum/domain/models/exercise.dart';
import '../../../curriculum/domain/models/item_type.dart';
import 'attempt.dart';

/// Normalizes an [Exercise] or [Assessment] into the shape the practice UI
/// needs, so one player widget can drive both without duplicating layout
/// and grading logic for two near-identical content shapes.
class PracticeItem extends Equatable {
  const PracticeItem({
    required this.id,
    required this.kind,
    required this.type,
    required this.prompt,
    required this.hints,
    this.code,
    this.expectedAnswer,
    this.solutionCode,
    this.solutionExplanation,
    this.options,
    this.correctOptionIndex,
    this.mcqExplanation,
    this.modelAnswer,
  });

  final String id;
  final ItemKind kind;
  final ItemType type;
  final String prompt;
  final List<String> hints;
  final String? code;
  final String? expectedAnswer;
  final String? solutionCode;
  final String? solutionExplanation;
  final List<String>? options;
  final int? correctOptionIndex;
  final String? mcqExplanation;
  final String? modelAnswer;

  /// The reveal-worthy explanation, regardless of which field it lives in
  /// on the source content.
  String? get revealExplanation =>
      solutionExplanation ?? mcqExplanation ?? modelAnswer;

  factory PracticeItem.fromExercise(Exercise exercise) => PracticeItem(
    id: exercise.id,
    kind: ItemKind.exercise,
    type: exercise.type,
    prompt: exercise.prompt,
    hints: exercise.hints,
    code: exercise.code,
    expectedAnswer: exercise.expectedAnswer,
    solutionCode: exercise.solutionCode,
    solutionExplanation: exercise.solutionExplanation,
  );

  factory PracticeItem.fromAssessment(Assessment assessment) => PracticeItem(
    id: assessment.id,
    kind: ItemKind.assessment,
    type: assessment.type,
    prompt: assessment.prompt,
    hints: const [],
    options: assessment.options,
    correctOptionIndex: assessment.correctOptionIndex,
    mcqExplanation: assessment.explanation,
    modelAnswer: assessment.modelAnswer,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    type,
    prompt,
    hints,
    code,
    expectedAnswer,
    solutionCode,
    solutionExplanation,
    options,
    correctOptionIndex,
    mcqExplanation,
    modelAnswer,
  ];
}
