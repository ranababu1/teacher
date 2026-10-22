import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/analytics/domain/models/learning_analytics.dart';
import 'package:teacher/features/coding_challenges/domain/models/coding_challenge.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/projects/domain/models/project.dart';
import 'package:teacher/features/projects/domain/models/project_overview.dart';
import 'package:teacher/features/study_plan/domain/models/study_plan.dart';
import 'package:teacher/features/study_plan/domain/study_plan_service.dart';
import 'package:teacher/features/study_plan/presentation/providers/study_plan_providers.dart';
import 'package:teacher/features/study_plan/presentation/screens/study_plan_screen.dart';
import 'package:teacher/features/system_design/domain/models/system_design_exercise.dart';

Concept _c(String id, String module, {List<String> prereqs = const []}) =>
    Concept(
      id: id,
      title: 'Concept $id',
      description: '',
      learningPathId: 'py',
      moduleId: module,
      topicId: module,
      difficulty: Difficulty.beginner,
      estimatedMinutes: 7,
      prerequisites: prereqs,
      learningObjectives: const [],
      explanation: const ConceptExplanation(sections: []),
      examples: const [],
      misconceptions: const [],
      exercises: const [],
      assessments: const [],
    );

final _path = LearningPath(
  id: 'py',
  title: 'Python',
  description: '',
  difficulty: Difficulty.beginner,
  iconName: 'python',
  estimatedHours: 1,
  modules: [
    CurriculumModule(
      learningPathId: 'py',
      id: 'm1',
      title: 'Basics',
      order: 0,
      concepts: [_c('a', 'm1'), _c('b', 'm1')],
    ),
    CurriculumModule(
      learningPathId: 'py',
      id: 'm2',
      title: 'Loops',
      order: 1,
      concepts: [_c('c', 'm2'), _c('d', 'm2')],
    ),
    CurriculumModule(
      learningPathId: 'py',
      id: 'm3',
      title: 'Files',
      order: 2,
      concepts: [_c('e', 'm3')],
    ),
  ],
);

ProjectOverview _project(
  String id, {
  Set<String> done = const {},
  bool ready = true,
  String? after = 'm1',
}) => ProjectOverview(
  project: Project(
    id: id,
    learningPathId: 'py',
    title: 'Project $id',
    summary: '',
    brief: '',
    difficulty: Difficulty.beginner,
    estimatedHours: 2,
    skills: const [],
    milestones: const [
      ProjectMilestone(id: 'm1', title: 'Setup', description: ''),
      ProjectMilestone(id: 'm2', title: 'Core', description: ''),
    ],
    rubric: const [],
    stretchGoals: const [],
    recommendedAfterModuleId: after,
  ),
  courseTitle: 'Python',
  completedMilestoneIds: done,
  recommendedTopicTitle: after == null ? null : 'Basics',
  isRecommendedTopicPassed: ready,
);

StudyPlanInputs _inputs({
  List<LearningPath>? started,
  Set<String> completed = const {},
  Map<String, Set<String>> passed = const {},
  List<Concept> due = const [],
  List<WeakConcept> weak = const [],
  List<ProjectOverview> projects = const [],
  Map<String, int> debugging = const {},
  Concept? next,
}) => StudyPlanInputs(
  startedPaths: started ?? [_path],
  completedConceptIds: completed,
  passedModuleIdsByPath: passed,
  dueReviews: due,
  weakConcepts: weak,
  projects: projects,
  debuggingCountByPath: debugging,
  nextConcept: next,
);

void main() {
  final service = StudyPlanService();

  test('no started course: one step pointing at the course list', () {
    final plan = service.build(_inputs(started: const []));
    expect(plan.steps.single.kind, PlanStepKind.startCourse);
  });

  test('orders review, weak spots, topic test, next lesson, applied work', () {
    final plan = service.build(
      _inputs(
        completed: {'a', 'b', 'c', 'd'},
        passed: {
          'py': {'m1'},
        },
        due: [_c('a', 'm1'), _c('b', 'm1'), _c('x', 'm1')],
        weak: const [
          WeakConcept(
            conceptId: 'b',
            title: 'Concept b',
            learningPathId: 'py',
            moduleId: 'm1',
            attempts: 6,
            accuracy: 0.33,
          ),
        ],
        projects: [_project('p')],
        debugging: {'py': 4},
        next: _c('e', 'm3', prereqs: ['d']),
      ),
    );
    expect(plan.steps.map((s) => s.kind), [
      PlanStepKind.review,
      PlanStepKind.strengthen,
      PlanStepKind.topicTest,
      PlanStepKind.learn,
      PlanStepKind.project,
      PlanStepKind.challenge,
    ]);
    expect(plan.steps[0].title, 'Review 3 due concepts');
    expect(plan.steps[0].reason, contains('and more'));
    expect(plan.steps[1].reason, contains('33% accuracy over 6'));
    expect(plan.steps[2].moduleId, 'm2');
    expect(plan.steps[3].conceptId, 'e');
    expect(plan.steps[4].title, 'Start "Project p"');
    expect(plan.totalMinutes, 9 + 10 + 10 + 7 + 45 + 15);
  });

  test(
    'in-progress project beats a ready one and names the next milestone',
    () {
      final plan = service.build(
        _inputs(
          projects: [
            _project('ready'),
            _project('wip', done: {'m1'}),
          ],
        ),
      );
      final step = plan.steps.single;
      expect(step.projectId, 'wip');
      expect(step.title, 'Project: Core');
    },
  );

  test('projects whose topic is not passed or that are done are skipped', () {
    final plan = service.build(
      _inputs(
        projects: [
          _project('not-ready', ready: false),
          _project('done', done: {'m1', 'm2'}),
          _project('no-topic', after: null),
        ],
      ),
    );
    expect(plan.steps, isEmpty);
  });

  test('two passed topics suggest a mock interview', () {
    final plan = service.build(
      _inputs(
        passed: {
          'py': {'m1', 'm2'},
        },
      ),
    );
    expect(plan.steps.single.kind, PlanStepKind.interview);
  });

  group('system design step', () {
    SystemDesignExercise ex(String id) => SystemDesignExercise(
      id: id,
      title: 'Design $id',
      difficulty: Difficulty.intermediate,
      estimatedMinutes: 40,
      summary: '',
      scenario: '',
      stages: const [],
      commonPitfalls: const [],
    );
    SystemDesignRecord rec(int best) => SystemDesignRecord(
      attempts: 1,
      bestScore: best,
      maxScore: 10,
      lastCompletedAt: DateTime(2026),
    );
    final sdPath = LearningPath(
      id: StudyPlanService.systemDesignPathId,
      title: 'System Design',
      description: '',
      difficulty: Difficulty.intermediate,
      iconName: 'sd',
      estimatedHours: 1,
      modules: const [],
    );
    StudyPlanInputs withDesign(
      List<({SystemDesignExercise exercise, SystemDesignRecord? record})> d, {
      List<LearningPath>? started,
    }) => StudyPlanInputs(
      startedPaths: started ?? [sdPath],
      completedConceptIds: const {},
      passedModuleIdsByPath: const {},
      dueReviews: const [],
      weakConcepts: const [],
      projects: const [],
      debuggingCountByPath: const {},
      systemDesign: d,
    );

    test('only for learners on the system design course', () {
      expect(
        service
            .build(
              withDesign([(exercise: ex('a'), record: null)], started: [_path]),
            )
            .steps,
        isEmpty,
      );
    });

    test('first untried exercise, else the weakest under 75%', () {
      var step = service
          .build(
            withDesign([
              (exercise: ex('a'), record: rec(9)),
              (exercise: ex('b'), record: null),
            ]),
          )
          .steps
          .single;
      expect(step.kind, PlanStepKind.systemDesign);
      expect(step.exerciseId, 'b');
      expect(step.title, 'Design: Design b');

      step = service
          .build(
            withDesign([
              (exercise: ex('a'), record: rec(6)),
              (exercise: ex('b'), record: rec(4)),
              (exercise: ex('c'), record: rec(9)),
            ]),
          )
          .steps
          .single;
      expect(step.exerciseId, 'b');
      expect(step.reason, contains('40%'));

      expect(
        service.build(withDesign([(exercise: ex('a'), record: rec(8))])).steps,
        isEmpty,
      );
    });
  });

  test('2+ passed topics also suggest an untried long-form challenge', () {
    LongFormChallenge ch(String id, String pathId) => LongFormChallenge(
      id: id,
      learningPathId: pathId,
      language: 'python',
      title: 'Ch $id',
      difficulty: Difficulty.intermediate,
      estimatedMinutes: 50,
      summary: '',
      statement: '',
      starterCode: '',
      parts: const [],
    );
    final plan = service.build(
      StudyPlanInputs(
        startedPaths: [_path],
        completedConceptIds: const {},
        passedModuleIdsByPath: const {
          'py': {'m1', 'm2'},
        },
        dueReviews: const [],
        weakConcepts: const [],
        projects: const [],
        debuggingCountByPath: const {},
        longChallenges: [
          (
            challenge: ch('done', 'py'),
            record: const ChallengeRecord(
              attempts: 1,
              bestScore: 6,
              maxScore: 6,
            ),
          ),
          (challenge: ch('other-course', 'go'), record: null),
          (challenge: ch('fresh', 'py'), record: null),
        ],
      ),
    );
    expect(plan.steps.map((s) => s.kind), [
      PlanStepKind.interview,
      PlanStepKind.longChallenge,
    ]);
    expect(plan.steps.last.challengeId, 'fresh');
    expect(plan.steps.last.minutes, 50);
  });

  test('caps the plan at maxSteps', () {
    final weak = [
      for (final id in ['a', 'b', 'c'])
        WeakConcept(
          conceptId: id,
          title: id,
          learningPathId: 'py',
          moduleId: 'm1',
          attempts: 5,
          accuracy: 0.2,
        ),
    ];
    final plan = service.build(
      _inputs(
        completed: {'a', 'b'},
        passed: {
          'py': {'m2', 'm3'},
        },
        due: [_c('a', 'm1')],
        weak: weak,
        projects: [_project('p', after: 'm2')],
        next: _c('c', 'm2'),
      ),
    );
    expect(plan.steps.length, StudyPlanService.maxSteps);
    expect(
      plan.steps.where((s) => s.kind == PlanStepKind.strengthen),
      hasLength(2),
    );
  });

  testWidgets('screen lists steps with reasons; empty and error states', (
    tester,
  ) async {
    Future<void> pump(Override o) async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [o],
          child: const MaterialApp(home: StudyPlanScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump(
      studyPlanProvider.overrideWith(
        (ref) async => const StudyPlan(
          careerGoal: 'Backend engineer',
          steps: [
            PlanStep(
              kind: PlanStepKind.review,
              title: 'Review 2 due concepts',
              reason: 'Due today.',
              minutes: 6,
            ),
          ],
        ),
      ),
    );
    expect(find.text('1. Review 2 due concepts'), findsOneWidget);
    expect(find.textContaining('Due today.'), findsOneWidget);
    expect(find.text('Goal: Backend engineer'), findsOneWidget);
    expect(find.textContaining('About 6 min'), findsOneWidget);

    await pump(
      studyPlanProvider.overrideWith((ref) async => const StudyPlan(steps: [])),
    );
    expect(find.textContaining("You're all caught up"), findsOneWidget);

    await pump(
      studyPlanProvider.overrideWith((ref) async => throw Exception('boom')),
    );
    expect(find.byType(StudyPlanScreen), findsOneWidget);
    expect(find.textContaining('1.'), findsNothing);
  });
}
