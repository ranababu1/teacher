import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/curriculum/domain/models/assessment.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/progress/data/learning_path_progress_repository_impl.dart';
import 'package:teacher/features/progress/data/module_test_progress_repository_impl.dart';
import 'package:teacher/features/skill_check/domain/apply_skill_check_placement_use_case.dart';
import 'package:teacher/features/skill_check/domain/models/skill_check.dart';
import 'package:teacher/features/skill_check/domain/skill_check_service.dart';
import 'package:teacher/features/skill_check/presentation/providers/skill_check_providers.dart';
import 'package:teacher/features/skill_check/presentation/screens/skill_check_screen.dart';

Assessment _mcq(String id) => Assessment(
  id: id,
  type: ItemType.multipleChoice,
  prompt: 'Q $id',
  options: const ['right', 'wrong'],
  correctOptionIndex: 0,
);

Concept _concept(String id, String moduleId, int mcqs) => Concept(
  id: id,
  title: id,
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
    for (var i = 0; i < mcqs; i++) _mcq('$id-q$i'),
    const Assessment(
      id: 'explain',
      type: ItemType.explanation,
      prompt: 'Explain',
    ),
  ],
);

LearningPath _path(int modules, {int mcqs = 3}) => LearningPath(
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
        concepts: [_concept('c$m', 'm$m', mcqs)],
      ),
  ],
);

Map<String, int> _answerAll(
  List<SkillCheckQuestion> qs,
  bool Function(SkillCheckQuestion) right,
) => {for (final q in qs) q.id: right(q) ? 0 : 1};

void main() {
  final service = SkillCheckService(random: Random(1));

  group('SkillCheckService.buildQuestions', () {
    test('short course: two MCQs per topic, in course order', () {
      final qs = service.buildQuestions(_path(4));
      expect(qs, hasLength(8));
      expect(qs.map((q) => q.moduleId).toList(), [
        'm0',
        'm0',
        'm1',
        'm1',
        'm2',
        'm2',
        'm3',
        'm3',
      ]);
      expect(
        qs.every((q) => q.assessment.type == ItemType.multipleChoice),
        isTrue,
      );
    });

    test('long course: one per topic, capped and spread across the course', () {
      final qs = service.buildQuestions(_path(30));
      expect(qs, hasLength(SkillCheckService.maxQuestions));
      expect(qs.first.moduleId, 'm0');
      expect(qs.map((q) => q.moduleId).toSet(), hasLength(16));
    });

    test('no multiple-choice content yields no questions', () {
      expect(service.buildQuestions(_path(3, mcqs: 0)), isEmpty);
    });
  });

  group('SkillCheckService.score', () {
    final path = _path(4);
    final qs = service.buildQuestions(path);

    test('leading perfect topics are tested out; start at the first miss', () {
      final result = service.score(
        path: path,
        questions: qs,
        answers: _answerAll(qs, (q) => q.moduleId != 'm2'),
      );
      expect(result.testedOutModuleIds, ['m0', 'm1']);
      expect(result.recommendedStartModule?.id, 'm2');
      expect(result.correct, 6);
      expect(result.scorePercent, 75);
    });

    test('a later perfect topic does not skip an earlier miss', () {
      final result = service.score(
        path: path,
        questions: qs,
        answers: _answerAll(qs, (q) => q.moduleId != 'm0'),
      );
      expect(result.testedOutModuleIds, isEmpty);
      expect(result.recommendedStartModule?.id, 'm0');
    });

    test('unanswered counts as not known', () {
      final result = service.score(path: path, questions: qs, answers: {});
      expect(result.scorePercent, 0);
      expect(result.recommendedStartModule?.id, 'm0');
    });

    test('everything right tests out the whole course', () {
      final result = service.score(
        path: path,
        questions: qs,
        answers: _answerAll(qs, (_) => true),
      );
      expect(result.testedOutModuleIds, hasLength(4));
      expect(result.recommendedStartModule, isNull);
    });
  });

  test(
    'applying placement starts the course and passes tested-out topics',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final pathRepo = LearningPathProgressRepositoryImpl(db);
      final moduleRepo = ModuleTestProgressRepositoryImpl(db);
      final path = _path(4);
      final qs = service.buildQuestions(path);
      final result = service.score(
        path: path,
        questions: qs,
        answers: _answerAll(qs, (q) => q.moduleId != 'm2'),
      );

      await ApplySkillCheckPlacementUseCase(
        pathProgress: pathRepo,
        moduleTests: moduleRepo,
      ).call(result);

      expect(await pathRepo.isPathStarted('py'), isTrue);
      expect(await moduleRepo.getPassedModuleIds('py'), {'m0', 'm1'});
    },
  );

  testWidgets('screen: answer, see placement, unlock', (tester) async {
    final path = _path(2, mcqs: 1);
    final qs = service.buildQuestions(path);
    SkillCheckResult? applied;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          skillCheckProvider('py')
              .overrideWith((ref) async => (path: path, questions: qs)),
          applySkillCheckPlacementProvider.overrideWithValue(
            (r) async => applied = r,
          ),
        ],
        child: const MaterialApp(home: SkillCheckScreen(pathId: 'py')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Skill Check'));
    await tester.pumpAndSettle();
    // Topic 0 right, topic 1 "I don't know".
    await tester.tap(find.text('right'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I don't know"));
    await tester.pumpAndSettle();

    expect(find.text('You scored 50%'), findsOneWidget);
    expect(find.textContaining('start at "Topic 1"'), findsOneWidget);
    await tester.tap(find.text('Unlock 1 topic'));
    await tester.pumpAndSettle();
    expect(applied?.testedOutModuleIds, ['m0']);
    expect(find.text('Go to "Topic 1"'), findsOneWidget);
  });

  testWidgets('screen: empty state when a course has no questions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          skillCheckProvider('py').overrideWith(
            (ref) async =>
                (path: _path(2, mcqs: 0), questions: <SkillCheckQuestion>[]),
          ),
        ],
        child: const MaterialApp(home: SkillCheckScreen(pathId: 'py')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('no skill-check questions'), findsOneWidget);
  });
}
