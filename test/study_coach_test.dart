import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/domain/models/roadmap_generation.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/models/study_coaching.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/teach_providers.dart';
import 'package:teacher/features/analytics/domain/models/learning_analytics.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/study_plan/domain/coach_study_plan_use_case.dart';
import 'package:teacher/features/study_plan/domain/models/study_plan.dart';
import 'package:teacher/features/study_plan/domain/study_plan_service.dart';
import 'package:teacher/features/study_plan/presentation/providers/study_plan_providers.dart';
import 'package:teacher/features/study_plan/presentation/screens/study_plan_screen.dart';

class _FakeAi implements AIProvider {
  _FakeAi({this.error});
  final Object? error;
  StudyCoachingRequest? lastRequest;

  @override
  Future<StudyCoachingAdvice> coachStudyPlan(
    StudyCoachingRequest request,
  ) async {
    lastRequest = request;
    if (error != null) throw error!;
    return const StudyCoachingAdvice(
      summary: 'Good momentum in Python.',
      weeklyFocus: 'Finish the Loops topic.',
      stepTips: ['Do it before new lessons.', 'Explain it aloud.'],
    );
  }

  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) =>
      throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _path = LearningPath(
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
      concepts: [],
    ),
    CurriculumModule(
      learningPathId: 'py',
      id: 'm2',
      title: 'Loops',
      order: 1,
      concepts: [],
    ),
  ],
);

const _inputs = StudyPlanInputs(
  startedPaths: [_path],
  completedConceptIds: {},
  passedModuleIdsByPath: {
    'py': {'m1'},
  },
  dueReviews: [],
  weakConcepts: [
    WeakConcept(
      conceptId: 'c',
      title: 'Closures',
      learningPathId: 'py',
      moduleId: 'm1',
      attempts: 6,
      accuracy: 0.5,
    ),
  ],
  projects: [],
  debuggingCountByPath: {},
);

const _plan = StudyPlan(
  careerGoal: 'Backend engineer',
  steps: [
    PlanStep(
      kind: PlanStepKind.review,
      title: 'Review 2 due concepts',
      reason: 'Due today.',
      minutes: 6,
    ),
    PlanStep(
      kind: PlanStepKind.strengthen,
      title: 'Strengthen Closures',
      reason: 'Low accuracy.',
      minutes: 10,
      conceptId: 'c',
    ),
  ],
);

void main() {
  test('request summarises courses, reviews and weak spots, not raw data', () {
    final r = CoachStudyPlanUseCase.buildRequest(plan: _plan, inputs: _inputs);
    expect(r.learnerSummary, contains('Python (1 of 2 topics passed)'));
    expect(r.learnerSummary, contains('Concepts due for review: 0.'));
    expect(r.learnerSummary, contains('Closures (50% over 6 attempts)'));
    expect(r.planSteps, [
      'Review 2 due concepts: Due today.',
      'Strengthen Closures: Low accuracy.',
    ]);
    expect(r.careerGoal, 'Backend engineer');
  });

  Future<void> pump(WidgetTester tester, _FakeAi ai) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          aiProviderProvider.overrideWithValue(ai),
          studyPlanInputsProvider.overrideWith((ref) async => _inputs),
          studyPlanProvider.overrideWith((ref) async => _plan),
        ],
        child: const MaterialApp(home: StudyPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> askCoach(WidgetTester tester) async {
    final button = find.text('Ask the AI Coach');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('coach advice shows summary, focus and per-step tips', (
    tester,
  ) async {
    final ai = _FakeAi();
    await pump(tester, ai);
    expect(ai.lastRequest, isNull, reason: 'no AI call until asked');
    await askCoach(tester);

    expect(ai.lastRequest!.planSteps, hasLength(2));
    expect(find.text('Good momentum in Python.'), findsOneWidget);
    expect(find.text('Finish the Loops topic.'), findsOneWidget);
    expect(find.textContaining('Coach: Do it before new lessons.'), findsOne);
    expect(find.textContaining('Coach: Explain it aloud.'), findsOne);
  });

  testWidgets('missing key or AI failure shows the plain message', (
    tester,
  ) async {
    await pump(
      tester,
      _FakeAi(
        error: const AIUnavailableException(
          'no key',
          'No Gemini API key is set yet. Add one in Settings.',
        ),
      ),
    );
    await askCoach(tester);
    expect(
      find.text('No Gemini API key is set yet. Add one in Settings.'),
      findsOneWidget,
    );
    expect(find.text('Try Again'), findsOneWidget);
    // The deterministic plan is still there.
    expect(find.text('1. Review 2 due concepts'), findsOneWidget);
  });
}
