import 'package:equatable/equatable.dart';

/// An open-ended interview question drawn from a course's explanation and
/// scenario assessments, with the model answer used for self-comparison.
class InterviewQuestion extends Equatable {
  const InterviewQuestion({
    required this.id,
    required this.learningPathId,
    required this.moduleId,
    required this.moduleTitle,
    required this.conceptId,
    required this.conceptTitle,
    required this.prompt,
    required this.modelAnswer,
    required this.isScenario,
  });

  final String id;
  final String learningPathId;
  final String moduleId;
  final String moduleTitle;
  final String conceptId;
  final String conceptTitle;
  final String prompt;
  final String modelAnswer;

  /// Real-world scenario question (vs. explain-a-concept).
  final bool isScenario;

  @override
  List<Object?> get props => [id, learningPathId, conceptId];
}

/// The learner's honest comparison of their answer with the model answer.
enum InterviewRating {
  nailedIt('Nailed it', 2),
  partly('Partly', 1),
  missed('Missed it', 0);

  const InterviewRating(this.label, this.points);

  final String label;
  final int points;
}

/// Outcome of an interview session.
class InterviewSummary extends Equatable {
  const InterviewSummary({required this.ratings, required this.questions});

  final Map<String, InterviewRating> ratings;
  final List<InterviewQuestion> questions;

  int get answered => ratings.length;

  /// Points earned out of the maximum (2 per answered question), 0-100.
  int get scorePercent {
    if (ratings.isEmpty) return 0;
    final points = ratings.values.fold(0, (sum, r) => sum + r.points);
    return (points * 100 / (ratings.length * 2)).round();
  }

  /// Questions rated below "Nailed it", in session order: what to revisit.
  List<InterviewQuestion> get toRevisit => [
    for (final q in questions)
      if (ratings[q.id] != null && ratings[q.id] != InterviewRating.nailedIt) q,
  ];

  @override
  List<Object?> get props => [ratings, questions];
}
