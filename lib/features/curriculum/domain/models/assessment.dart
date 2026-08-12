import 'package:equatable/equatable.dart';

import 'item_type.dart';

/// A formally-scored knowledge check. See instructions.md section 16.
class Assessment extends Equatable {
  const Assessment({
    required this.id,
    required this.type,
    required this.prompt,
    this.options,
    this.correctOptionIndex,
    this.explanation,
    this.modelAnswer,
  });

  final String id;
  final ItemType type;
  final String prompt;

  /// multipleChoice only.
  final List<String>? options;
  final int? correctOptionIndex;
  final String? explanation;

  /// shortAnswer / explanation / scenario — shown for self-comparison.
  final String? modelAnswer;

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String,
      type: ItemType.fromJson(json['type'] as String),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctOptionIndex: json['correctOptionIndex'] as int?,
      explanation: json['explanation'] as String?,
      modelAnswer: json['modelAnswer'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, prompt, options, correctOptionIndex, explanation, modelAnswer];
}
