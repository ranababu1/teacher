import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/difficulty.dart';

/// One step of a design walkthrough (requirements, estimates, API, ...).
class DesignStage extends Equatable {
  const DesignStage({
    required this.id,
    required this.title,
    required this.prompt,
    required this.hints,
    required this.modelAnswer,
  });

  final String id;
  final String title;
  final String prompt;
  final List<String> hints;
  final String modelAnswer;

  factory DesignStage.fromJson(Map<String, dynamic> json) => DesignStage(
    id: json['id'] as String,
    title: json['title'] as String,
    prompt: json['prompt'] as String,
    hints: (json['hints'] as List<dynamic>? ?? const []).cast<String>(),
    modelAnswer: json['modelAnswer'] as String,
  );

  @override
  List<Object?> get props => [id, title, prompt, hints, modelAnswer];
}

/// A staged system design exercise, bundled in
/// assets/system_design/exercises.json.
class SystemDesignExercise extends Equatable {
  const SystemDesignExercise({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.summary,
    required this.scenario,
    required this.stages,
    required this.commonPitfalls,
  });

  final String id;
  final String title;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final String summary;
  final String scenario;
  final List<DesignStage> stages;
  final List<String> commonPitfalls;

  /// Points available when every stage is rated "Nailed it" (2 each).
  int get maxScore => stages.length * 2;

  factory SystemDesignExercise.fromJson(Map<String, dynamic> json) =>
      SystemDesignExercise(
        id: json['id'] as String,
        title: json['title'] as String,
        difficulty: Difficulty.fromJson(json['difficulty'] as String),
        estimatedMinutes: json['estimatedMinutes'] as int,
        summary: json['summary'] as String,
        scenario: json['scenario'] as String,
        stages: (json['stages'] as List<dynamic>)
            .map((s) => DesignStage.fromJson(s as Map<String, dynamic>))
            .toList(),
        commonPitfalls: (json['commonPitfalls'] as List<dynamic>? ?? const [])
            .cast<String>(),
      );

  @override
  List<Object?> get props => [id, title, stages];
}

/// Best and latest result for one exercise.
class SystemDesignRecord extends Equatable {
  const SystemDesignRecord({
    required this.attempts,
    required this.bestScore,
    required this.maxScore,
    required this.lastCompletedAt,
  });

  final int attempts;
  final int bestScore;
  final int maxScore;
  final DateTime lastCompletedAt;

  int get bestPercent =>
      maxScore == 0 ? 0 : (bestScore * 100 / maxScore).round();

  @override
  List<Object?> get props => [attempts, bestScore, maxScore, lastCompletedAt];
}
