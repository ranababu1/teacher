import 'package:equatable/equatable.dart';

import 'item_type.dart';

/// A practice item. Fields are optional/present depending on [type] —
/// see instructions.md section 16 for the shape of each type.
class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.hints,
    this.code,
    this.expectedAnswer,
    this.solutionCode,
    this.solutionExplanation,
    this.difficultyLevel,
  });

  final String id;
  final ItemType type;
  final String prompt;
  final List<String> hints;

  /// Source code shown with the prompt (predictOutput, debugging).
  final String? code;

  /// Expected textual answer for auto-gradable types (predictOutput).
  final String? expectedAnswer;

  /// Corrected/model code (debugging, coding).
  final String? solutionCode;

  final String? solutionExplanation;

  /// 1-7 per the difficulty ladder in instructions.md section 17.
  final int? difficultyLevel;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      type: ItemType.fromJson(json['type'] as String),
      prompt: json['prompt'] as String,
      hints: (json['hints'] as List<dynamic>? ?? const []).cast<String>(),
      code: json['code'] as String?,
      expectedAnswer: json['expectedAnswer'] as String?,
      solutionCode: json['solutionCode'] as String?,
      solutionExplanation: json['solutionExplanation'] as String?,
      difficultyLevel: json['difficultyLevel'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, type, prompt, hints, code, expectedAnswer, solutionCode,
      solutionExplanation, difficultyLevel];
}
