import 'package:equatable/equatable.dart';

/// Cross-cutting performance stats derived from attempt history, shown on
/// the Progress screen. See instructions.md section 34 — "Avoid vanity
/// metrics. Progress should represent actual learning."
class LearningStats extends Equatable {
  const LearningStats({
    required this.assessmentAccuracy,
    required this.codingPerformance,
    required this.explanationPerformance,
    required this.recentImprovementDelta,
    required this.totalAttempts,
  });

  /// 0.0-1.0 fraction of assessment attempts that met the "success" bar.
  /// Null if no assessments have been attempted yet.
  final double? assessmentAccuracy;

  /// Average coding mastery dimension across all concepts that have at
  /// least one coding attempt. Null if none yet.
  final double? codingPerformance;

  final double? explanationPerformance;

  /// Difference in average attempt quality between the most recent half
  /// and the earlier half of the last 10 attempts. Positive = improving.
  /// Null if there isn't enough recent history to compare.
  final double? recentImprovementDelta;

  final int totalAttempts;

  @override
  List<Object?> get props => [
    assessmentAccuracy,
    codingPerformance,
    explanationPerformance,
    recentImprovementDelta,
    totalAttempts,
  ];
}
