import 'package:equatable/equatable.dart';

/// What the AI coach sees: a plain-text summary of the learner's state and
/// the deterministic study plan the app already built. The coach explains
/// and sharpens that plan; it never invents content the app lacks.
class StudyCoachingRequest extends Equatable {
  const StudyCoachingRequest({
    required this.learnerSummary,
    required this.planSteps,
    this.careerGoal,
  });

  final String learnerSummary;

  /// One line per plan step, in order ("Review 3 due concepts: ...").
  final List<String> planSteps;
  final String? careerGoal;

  @override
  List<Object?> get props => [learnerSummary, planSteps, careerGoal];
}

class StudyCoachingAdvice extends Equatable {
  const StudyCoachingAdvice({
    required this.summary,
    required this.weeklyFocus,
    required this.stepTips,
  });

  /// Two or three sentences on where the learner stands.
  final String summary;

  /// One concrete focus for the coming week.
  final String weeklyFocus;

  /// One tip per plan step, index-aligned (may be shorter than the plan).
  final List<String> stepTips;

  @override
  List<Object?> get props => [summary, weeklyFocus, stepTips];
}
