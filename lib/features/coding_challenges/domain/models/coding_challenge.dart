import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/difficulty.dart';

/// One part of a long-form challenge; parts build on each other.
class ChallengePart extends Equatable {
  const ChallengePart({
    required this.id,
    required this.title,
    required this.task,
    required this.hints,
    required this.checks,
    required this.solution,
    required this.explanation,
  });

  final String id;
  final String title;

  /// Markdown.
  final String task;
  final List<String> hints;

  /// Behaviours to verify by hand (there is no code runner, see
  /// instructions.md section 33).
  final List<String> checks;
  final String solution;
  final String explanation;

  factory ChallengePart.fromJson(Map<String, dynamic> json) => ChallengePart(
    id: json['id'] as String,
    title: json['title'] as String,
    task: json['task'] as String,
    hints: (json['hints'] as List<dynamic>? ?? const []).cast<String>(),
    checks: (json['checks'] as List<dynamic>? ?? const []).cast<String>(),
    solution: json['solution'] as String,
    explanation: json['explanation'] as String,
  );

  @override
  List<Object?> get props => [id, title, task, solution];
}

/// A multi-part coding challenge bundled in
/// assets/coding_challenges/challenges.json.
class LongFormChallenge extends Equatable {
  const LongFormChallenge({
    required this.id,
    required this.learningPathId,
    required this.language,
    required this.title,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.summary,
    required this.statement,
    required this.starterCode,
    required this.parts,
  });

  final String id;
  final String learningPathId;

  /// Highlighting language for CodeBlock.
  final String language;
  final String title;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final String summary;

  /// Markdown.
  final String statement;
  final String starterCode;
  final List<ChallengePart> parts;

  int get maxScore => parts.length * 2;

  factory LongFormChallenge.fromJson(Map<String, dynamic> json) =>
      LongFormChallenge(
        id: json['id'] as String,
        learningPathId: json['learningPathId'] as String,
        language: json['language'] as String,
        title: json['title'] as String,
        difficulty: Difficulty.fromJson(json['difficulty'] as String),
        estimatedMinutes: json['estimatedMinutes'] as int,
        summary: json['summary'] as String,
        statement: json['statement'] as String,
        starterCode: json['starterCode'] as String? ?? '',
        parts: (json['parts'] as List<dynamic>)
            .map((p) => ChallengePart.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, title, parts];
}

/// Best and latest result for one challenge.
class ChallengeRecord extends Equatable {
  const ChallengeRecord({
    required this.attempts,
    required this.bestScore,
    required this.maxScore,
  });

  final int attempts;
  final int bestScore;
  final int maxScore;

  int get bestPercent =>
      maxScore == 0 ? 0 : (bestScore * 100 / maxScore).round();

  @override
  List<Object?> get props => [attempts, bestScore, maxScore];
}
