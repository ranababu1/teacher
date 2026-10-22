import '../../analytics/domain/models/learning_analytics.dart';
import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../projects/domain/models/project_overview.dart';
import 'models/study_plan.dart';

/// Everything the planner looks at. Built by the provider from the
/// repositories, so the service itself is pure and easy to test.
class StudyPlanInputs {
  const StudyPlanInputs({
    required this.startedPaths,
    required this.completedConceptIds,
    required this.passedModuleIdsByPath,
    required this.dueReviews,
    required this.weakConcepts,
    required this.projects,
    required this.debuggingCountByPath,
    this.nextConcept,
    this.careerGoal,
  });

  /// Started courses, in the order the learner sees them.
  final List<LearningPath> startedPaths;
  final Set<String> completedConceptIds;
  final Map<String, Set<String>> passedModuleIdsByPath;
  final List<Concept> dueReviews;
  final List<WeakConcept> weakConcepts;
  final List<ProjectOverview> projects;
  final Map<String, int> debuggingCountByPath;

  /// The next lesson (from the Continue Learning or recommendation logic).
  final Concept? nextConcept;
  final String? careerGoal;
}

/// Builds a short, ordered, personal study plan from the learner's state:
/// overdue memory first, then weak spots, then forward progress (topic
/// test, next lesson), then applied work (project, challenge, interview).
///
/// Deterministic and offline. Each step says why it is there.
class StudyPlanService {
  static const maxSteps = 6;

  StudyPlan build(StudyPlanInputs i) {
    final steps = <PlanStep>[];

    if (i.startedPaths.isEmpty) {
      return StudyPlan(
        careerGoal: i.careerGoal,
        steps: const [
          PlanStep(
            kind: PlanStepKind.startCourse,
            title: 'Pick your first course',
            reason:
                'Your plan grows from what you study. Start a course, or '
                'take its skill check to skip what you already know.',
            minutes: 5,
          ),
        ],
      );
    }

    if (i.dueReviews.isNotEmpty) {
      final n = i.dueReviews.length;
      steps.add(
        PlanStep(
          kind: PlanStepKind.review,
          title: 'Review $n due concept${n == 1 ? '' : 's'}',
          reason:
              'Spaced review is cheapest right when it is due. Includes '
              '${i.dueReviews.take(2).map((c) => c.title).join(' and ')}'
              '${n > 2 ? ' and more' : ''}.',
          minutes: (n * 3).clamp(3, 15),
        ),
      );
    }

    for (final w in i.weakConcepts.take(2)) {
      steps.add(
        PlanStep(
          kind: PlanStepKind.strengthen,
          title: 'Strengthen ${w.title}',
          reason:
              '${(w.accuracy * 100).round()}% accuracy over ${w.attempts} '
              'attempts. A short practice set will lock it in.',
          minutes: 10,
          pathId: w.learningPathId,
          moduleId: w.moduleId,
          conceptId: w.conceptId,
        ),
      );
    }

    final ready = _readyTopicTest(i);
    if (ready != null) steps.add(ready);

    final next = i.nextConcept;
    if (next != null) {
      steps.add(
        PlanStep(
          kind: PlanStepKind.learn,
          title: 'Learn ${next.title}',
          reason: next.prerequisites.isEmpty
              ? 'The next lesson in your course.'
              : 'The next lesson. Its prerequisites are already behind you.',
          minutes: next.estimatedMinutes,
          pathId: next.learningPathId,
          moduleId: next.moduleId,
          conceptId: next.id,
        ),
      );
    }

    final project = _project(i);
    if (project != null) steps.add(project);

    final applied = _challengeOrInterview(i);
    if (applied != null) steps.add(applied);

    return StudyPlan(
      careerGoal: i.careerGoal,
      steps: steps.take(maxSteps).toList(),
    );
  }

  /// First topic, in course order, whose lessons are all done but whose
  /// test has not been passed yet.
  PlanStep? _readyTopicTest(StudyPlanInputs i) {
    for (final path in i.startedPaths) {
      final passed = i.passedModuleIdsByPath[path.id] ?? const {};
      for (final m in path.modules) {
        if (passed.contains(m.id) || m.concepts.isEmpty) continue;
        if (m.concepts.every((c) => i.completedConceptIds.contains(c.id))) {
          return PlanStep(
            kind: PlanStepKind.topicTest,
            title: 'Take the ${m.title} test',
            reason:
                'You finished every lesson in this topic. Passing the test '
                'unlocks the next one.',
            minutes: 10,
            pathId: path.id,
            moduleId: m.id,
          );
        }
      }
    }
    return null;
  }

  PlanStep? _project(StudyPlanInputs i) {
    final started = {for (final p in i.startedPaths) p.id};
    final candidates = i.projects
        .where(
          (o) => !o.isComplete && started.contains(o.project.learningPathId),
        )
        .toList();
    final inProgress = candidates.where((o) => o.isStarted).firstOrNull;
    if (inProgress != null) {
      final nextMilestone = inProgress.project.milestones.firstWhere(
        (m) => !inProgress.completedMilestoneIds.contains(m.id),
      );
      return PlanStep(
        kind: PlanStepKind.project,
        title: 'Project: ${nextMilestone.title}',
        reason:
            'Next milestone of "${inProgress.project.title}" '
            '(${inProgress.completedCount}/${inProgress.totalCount} done).',
        minutes: 45,
        pathId: inProgress.project.learningPathId,
        projectId: inProgress.project.id,
      );
    }
    final readyOne = candidates
        .where(
          (o) =>
              o.isRecommendedTopicPassed &&
              o.project.recommendedAfterModuleId != null,
        )
        .firstOrNull;
    if (readyOne == null) return null;
    return PlanStep(
      kind: PlanStepKind.project,
      title: 'Start "${readyOne.project.title}"',
      reason:
          'You passed "${readyOne.recommendedTopicTitle}", so you are ready '
          'to apply it in a real build.',
      minutes: 45,
      pathId: readyOne.project.learningPathId,
      projectId: readyOne.project.id,
    );
  }

  PlanStep? _challengeOrInterview(StudyPlanInputs i) {
    for (final path in i.startedPaths) {
      final passed = (i.passedModuleIdsByPath[path.id] ?? const {}).length;
      if (passed >= 2) {
        return PlanStep(
          kind: PlanStepKind.interview,
          title: 'Mock interview: ${path.title}',
          reason:
              'You have passed $passed topics. Explaining them out loud is '
              'the best test of real understanding.',
          minutes: 15,
          pathId: path.id,
        );
      }
    }
    for (final path in i.startedPaths) {
      final passed = (i.passedModuleIdsByPath[path.id] ?? const {}).length;
      if (passed >= 1 && (i.debuggingCountByPath[path.id] ?? 0) > 0) {
        return PlanStep(
          kind: PlanStepKind.challenge,
          title: 'Debugging session: ${path.title}',
          reason:
              'Finding bugs in code you did not write builds the skill '
              'lessons cannot.',
          minutes: 15,
          pathId: path.id,
        );
      }
    }
    return null;
  }
}
