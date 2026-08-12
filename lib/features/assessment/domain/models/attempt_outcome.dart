/// Self-rating for items that can't be graded deterministically, modeled
/// after spaced-repetition "Again/Hard/Good/Easy" ratings.
enum SelfRating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const SelfRating(this.score);

  final int score;

  String get label => switch (this) {
    SelfRating.again => 'Again',
    SelfRating.hard => 'Hard',
    SelfRating.good => 'Good',
    SelfRating.easy => 'Easy',
  };
}

/// Coarse performance bucket used to drive review scheduling — see
/// instructions.md section 23.
enum PerformanceBucket { poor, good, excellent }

/// The result of a learner submitting a response to an [Exercise] or
/// [Assessment], before it's persisted as an Attempt.
class AttemptOutcome {
  const AttemptOutcome({
    required this.isCorrect,
    required this.selfRating,
    required this.hintsUsed,
    this.userResponse,
  });

  /// Set for auto-gradable items (multipleChoice). Null otherwise.
  final bool? isCorrect;

  /// Set for self-assessed items. Null for auto-graded items.
  final SelfRating? selfRating;

  final int hintsUsed;
  final String? userResponse;

  /// A single 0.0-1.0 quality score, regardless of whether this was
  /// auto-graded or self-rated, used by the mastery calculator.
  double get qualityScore {
    if (isCorrect != null) return isCorrect! ? 1.0 : 0.15;
    final rating = selfRating ?? SelfRating.good;
    return switch (rating) {
      SelfRating.again => 0.1,
      SelfRating.hard => 0.4,
      SelfRating.good => 0.75,
      SelfRating.easy => 1.0,
    };
  }

  PerformanceBucket get performanceBucket {
    if (isCorrect != null) {
      return isCorrect! ? PerformanceBucket.good : PerformanceBucket.poor;
    }
    return switch (selfRating ?? SelfRating.good) {
      SelfRating.again => PerformanceBucket.poor,
      SelfRating.hard => PerformanceBucket.poor,
      SelfRating.good => PerformanceBucket.good,
      SelfRating.easy => PerformanceBucket.excellent,
    };
  }
}
