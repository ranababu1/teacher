import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/challenges/domain/challenge_service.dart';
import 'package:teacher/features/challenges/presentation/providers/challenge_providers.dart';
import 'package:teacher/features/challenges/presentation/screens/challenge_lab_screen.dart';
import 'package:teacher/features/challenges/presentation/screens/challenge_set_screen.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/exercise.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';

Exercise _ex(String id, ItemType type, int level) => Exercise(
  id: id,
  type: type,
  prompt: 'Prompt $id',
  hints: const [],
  difficultyLevel: level,
);

Concept _concept(String id, List<Exercise> exercises) => Concept(
  id: id,
  title: 'Concept $id',
  description: '',
  learningPathId: 'py',
  moduleId: 'm',
  topicId: 'm',
  difficulty: Difficulty.beginner,
  estimatedMinutes: 5,
  prerequisites: const [],
  learningObjectives: const [],
  explanation: const ConceptExplanation(sections: []),
  examples: const [],
  misconceptions: const [],
  exercises: exercises,
  assessments: const [],
);

LearningPath _path() => LearningPath(
  id: 'py',
  title: 'Python',
  description: '',
  difficulty: Difficulty.beginner,
  iconName: 'python',
  estimatedHours: 1,
  modules: [
    CurriculumModule(
      learningPathId: 'py',
      id: 'm',
      title: 'M',
      order: 0,
      concepts: [
        _concept('a', [
          _ex('a1', ItemType.debugging, 5),
          _ex('a2', ItemType.debugging, 1),
          _ex('a3', ItemType.coding, 2),
        ]),
        _concept('b', [_ex('b1', ItemType.debugging, 3)]),
        _concept('c', [
          _ex('c1', ItemType.debugging, 2),
          _ex('c2', ItemType.predictOutput, 1),
        ]),
        _concept('d', [_ex('d1', ItemType.debugging, 4)]),
      ],
    ),
  ],
);

void main() {
  final service = ChallengeService(random: Random(7));

  test('counts per kind come from exercise types', () {
    expect(service.counts(_path()), {
      ChallengeKind.debugging: 5,
      ChallengeKind.coding: 1,
      ChallengeKind.scenario: 0,
    });
  });

  test('a set has 3 challenges from distinct concepts, easiest first', () {
    final set = service.buildSet(_path(), ChallengeKind.debugging);
    expect(set, hasLength(3));
    expect(set.map((c) => c.concept.id).toSet(), hasLength(3));
    final levels = set.map((c) => c.exercise.difficultyLevel!).toList();
    expect(levels, [...levels]..sort());
  });

  test('small pools give smaller sets; unknown kind names are null', () {
    expect(service.buildSet(_path(), ChallengeKind.coding), hasLength(1));
    expect(service.buildSet(_path(), ChallengeKind.scenario), isEmpty);
    expect(ChallengeKind.fromName('coding'), ChallengeKind.coding);
    expect(ChallengeKind.fromName('nope'), isNull);
  });

  testWidgets('lab lists kinds with counts and disables empty ones', (
    tester,
  ) async {
    final path = _path();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeCoursesProvider.overrideWith(
            (ref) async => [(path: path, counts: service.counts(path))],
          ),
        ],
        child: const MaterialApp(home: ChallengeLabScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Debugging Sessions'), findsOneWidget);
    expect(find.textContaining('5 available'), findsOneWidget);
    expect(find.text('None in this course yet.'), findsOneWidget);
  });

  testWidgets('set screen: empty state and unknown type', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeSetProvider((pathId: 'py', kind: ChallengeKind.scenario))
              .overrideWith(
                (ref) async => (path: _path(), challenges: <Challenge>[]),
              ),
        ],
        child: const MaterialApp(
          home: ChallengeSetScreen(pathId: 'py', kindName: 'scenario'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No challenges of this type'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        child: const MaterialApp(
          home: ChallengeSetScreen(pathId: 'py', kindName: 'bogus'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unknown challenge type.'), findsOneWidget);
  });
}
