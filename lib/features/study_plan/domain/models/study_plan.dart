import 'package:equatable/equatable.dart';

enum PlanStepKind {
  review,
  strengthen,
  topicTest,
  learn,
  project,
  challenge,
  interview,
  startCourse,
}

/// One suggested activity, with enough ids for the screen to open it.
class PlanStep extends Equatable {
  const PlanStep({
    required this.kind,
    required this.title,
    required this.reason,
    required this.minutes,
    this.pathId,
    this.moduleId,
    this.conceptId,
    this.projectId,
  });

  final PlanStepKind kind;
  final String title;

  /// Why this step is in the plan, in plain words.
  final String reason;
  final int minutes;
  final String? pathId;
  final String? moduleId;
  final String? conceptId;
  final String? projectId;

  @override
  List<Object?> get props => [
    kind,
    title,
    reason,
    minutes,
    pathId,
    moduleId,
    conceptId,
    projectId,
  ];
}

class StudyPlan extends Equatable {
  const StudyPlan({required this.steps, this.careerGoal});

  final List<PlanStep> steps;
  final String? careerGoal;

  int get totalMinutes => steps.fold(0, (s, x) => s + x.minutes);

  @override
  List<Object?> get props => [steps, careerGoal];
}
