import 'package:equatable/equatable.dart';

import 'mastery_status.dart';

/// Aggregated progress for a whole learning path — feeds the Dashboard and
/// Progress screens. See instructions.md sections 8 and 34.
class PathProgressSummary extends Equatable {
  const PathProgressSummary({
    required this.learningPathId,
    required this.title,
    required this.totalConcepts,
    required this.overallPercent,
    required this.statusCounts,
  });

  final String learningPathId;
  final String title;
  final int totalConcepts;

  /// 0.0 - 1.0, average mastery across all concepts (not-started counts as 0).
  final double overallPercent;

  final Map<MasteryStatus, int> statusCounts;

  int countOf(MasteryStatus status) => statusCounts[status] ?? 0;

  int get masteredCount => countOf(MasteryStatus.mastered);
  int get needsReviewCount => countOf(MasteryStatus.needsReview);
  int get inProgressCount =>
      countOf(MasteryStatus.learning) + countOf(MasteryStatus.developing) +
      countOf(MasteryStatus.proficient);

  @override
  List<Object?> get props => [learningPathId, title, totalConcepts, overallPercent, statusCounts];
}
