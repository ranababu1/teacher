import 'dart:math';

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

  static final _positional = RegExp(
    r'\b([Oo]ption|[Cc]hoice|[Aa]nswer)s? (#?\d|[A-F])\b|(?<!\w)\([A-F]\)|'
    r'\b([Ff]irst|[Ss]econd|[Tt]hird|[Ff]ourth|[Ll]ast|[Pp]revious) '
    r'(option|choice|answer)\b|\bof the above\b',
  );

  /// A copy with the options in random order, so the answer's position
  /// gives nothing away. Returned unchanged when it is not a valid
  /// multiple-choice item, or when its text refers to options by position
  /// (AI-written questions can) and reordering would make it wrong.
  Assessment withShuffledOptions(Random random) {
    final options = this.options;
    final correct = correctOptionIndex;
    if (options == null ||
        correct == null ||
        correct < 0 ||
        correct >= options.length ||
        [prompt, ...options, ?explanation].any(_positional.hasMatch)) {
      return this;
    }
    final order = List.generate(options.length, (i) => i)..shuffle(random);
    return Assessment(
      id: id,
      type: type,
      prompt: prompt,
      options: [for (final i in order) options[i]],
      correctOptionIndex: order.indexOf(correct),
      explanation: explanation,
      modelAnswer: modelAnswer,
    );
  }

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
  List<Object?> get props => [
    id,
    type,
    prompt,
    options,
    correctOptionIndex,
    explanation,
    modelAnswer,
  ];
}
