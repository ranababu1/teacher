import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../progress/domain/models/concept_mastery.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/models/attempt.dart';
import '../../domain/models/learning_stats.dart';
import 'assessment_providers.dart';

double _qualityOf(Attempt attempt) {
  if (attempt.isCorrect != null) return attempt.isCorrect! ? 1.0 : 0.15;
  return switch (attempt.selfRating) {
    1 => 0.1,
    2 => 0.4,
    3 => 0.75,
    4 => 1.0,
    _ => 0.75,
  };
}

double? _averageDimension(
  List<ConceptMastery> masteryList,
  double Function(ConceptMastery) dimension,
) {
  final touched = masteryList
      .map(dimension)
      .where((score) => score > 0)
      .toList();
  if (touched.isEmpty) return null;
  return touched.reduce((a, b) => a + b) / touched.length;
}

final learningStatsProvider = FutureProvider<LearningStats>((ref) async {
  final attempts = await ref
      .watch(attemptsRepositoryProvider)
      .getRecentAttempts(limit: 50);
  final masteryList = await ref.watch(allMasteryProvider.future);

  final assessmentAttempts = attempts
      .where((a) => a.itemKind == ItemKind.assessment)
      .toList();
  final assessmentAccuracy = assessmentAttempts.isEmpty
      ? null
      : assessmentAttempts.where((a) => _qualityOf(a) >= 0.6).length /
            assessmentAttempts.length;

  final codingPerformance = _averageDimension(
    masteryList,
    (m) => m.codingScore,
  );
  final explanationPerformance = _averageDimension(
    masteryList,
    (m) => m.explanationScore,
  );

  double? recentImprovementDelta;
  final recentSample = attempts.take(10).toList(); // newest first
  if (recentSample.length >= 4) {
    final half = recentSample.length ~/ 2;
    final newer = recentSample.sublist(0, half);
    final older = recentSample.sublist(half);
    final newerAvg =
        newer.map(_qualityOf).reduce((a, b) => a + b) / newer.length;
    final olderAvg =
        older.map(_qualityOf).reduce((a, b) => a + b) / older.length;
    recentImprovementDelta = newerAvg - olderAvg;
  }

  return LearningStats(
    assessmentAccuracy: assessmentAccuracy,
    codingPerformance: codingPerformance,
    explanationPerformance: explanationPerformance,
    recentImprovementDelta: recentImprovementDelta,
    totalAttempts: attempts.length,
  );
});
