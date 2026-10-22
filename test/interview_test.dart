import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/interview/domain/interview_service.dart';
import 'package:teacher/features/interview/domain/models/interview.dart';
import 'package:teacher/features/interview/presentation/providers/interview_providers.dart';
import 'package:teacher/features/interview/presentation/screens/interview_session_screen.dart';

Concept _concept(String id, String moduleId, {bool scenario = false}) =>
    Concept(
      id: id,
      title: 'Concept $id',
      description: '',
      learningPathId: 'py',
      moduleId: moduleId,
      topicId: moduleId,
      difficulty: Difficulty.beginner,
      estimatedMinutes: 5,
      prerequisites: const [],
      learningObjectives: const [],
      explanation: const ConceptExplanation(sections: []),
      examples: const [],
      misconceptions: const [],
      exercises: const [],
      assessments: [
        Assessment(
          id: '$id-explain',
          type: ItemType.explanation,
          prompt: 'Explain $id',
          modelAnswer: 'Model $id',
        ),
        if (scenario)
          Assessment(
            id: '$id-scenario',
            type: ItemType.scenario,
            prompt: 'Scenario $id',
            modelAnswer: 'Scenario model $id',
          ),
        Assessment(
          id: '$id-blank',
          type: ItemType.explanation,
          prompt: 'No model answer',
        ),
        Assessment(
          id: '$id-mcq',
          type: ItemType.multipleChoice,
          prompt: 'MCQ',
          options: const ['a', 'b'],
          correctOptionIndex: 0,
        ),
      ],
    );

LearningPath _path(int modules, {int scenarios = 0}) => LearningPath(
  id: 'py',
  title: 'Python',
  description: '',
  difficulty: Difficulty.beginner,
  iconName: 'python',
  estimatedHours: 1,
  modules: [
    for (var m = 0; m < modules; m++)
      CurriculumModule(
        learningPathId: 'py',
        id: 'm$m',
        title: 'Topic $m',
        order: m,
        concepts: [_concept('c$m', 'm$m', scenario: m < scenarios)],
      ),
  ],
);

void main() {
  final service = InterviewService(random: Random(3));

  test('bank holds explanation and scenario items with model answers only', () {
    final bank = service.questionBank(_path(3, scenarios: 1));
    expect(bank.map((q) => q.id), [
      'c0-explain',
      'c0-scenario',
      'c1-explain',
      'c2-explain',
    ]);
    expect(bank[1].isScenario, isTrue);
  });

  test('session: 5 questions, up to 2 scenarios, distinct topics first', () {
    final session = service.buildSession(_path(8, scenarios: 4));
    expect(session, hasLength(5));
    expect(session.where((q) => q.isScenario), hasLength(2));
    expect(session.map((q) => q.id).toSet(), hasLength(5));
    final nonScenarioTopics = session
        .where((q) => !q.isScenario)
        .map((q) => q.moduleId);
    expect(nonScenarioTopics.toSet(), hasLength(3));
  });

  test('small bank gives a shorter session', () {
    expect(service.buildSession(_path(2)), hasLength(2));
    expect(service.buildSession(_path(0)), isEmpty);
  });

  test('summary scoring and revisit list', () {
    final qs = service.questionBank(_path(3));
    final summary = InterviewSummary(
      questions: qs,
      ratings: {
        qs[0].id: InterviewRating.nailedIt,
        qs[1].id: InterviewRating.partly,
        qs[2].id: InterviewRating.missed,
      },
    );
    expect(summary.scorePercent, 50);
    expect(summary.toRevisit.map((q) => q.id), [qs[1].id, qs[2].id]);
    expect(const InterviewSummary(questions: [], ratings: {}).scorePercent, 0);
  });

  testWidgets('session flow: reveal, rate, summary', (tester) async {
    final path = _path(2);
    final qs = service.questionBank(path);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          interviewSessionProvider('py')
              .overrideWith((ref) async => (path: path, questions: qs)),
        ],
        child: const MaterialApp(home: InterviewSessionScreen(pathId: 'py')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Question 1 of 2'), findsOneWidget);
    await tester.tap(find.text('Reveal Model Answer'));
    await tester.pumpAndSettle();
    expect(find.text('Model c0'), findsOneWidget);
    await tester.tap(find.text('Nailed it'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reveal Model Answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Missed it'));
    await tester.pumpAndSettle();
    expect(find.text('Interview score: 50%'), findsOneWidget);
    expect(find.text('Concept c1'), findsOneWidget);
  });

  testWidgets('session: empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          interviewSessionProvider('py').overrideWith(
            (ref) async => (path: _path(0), questions: <InterviewQuestion>[]),
          ),
        ],
        child: const MaterialApp(home: InterviewSessionScreen(pathId: 'py')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No interview questions'), findsOneWidget);
  });
}
