import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/analytics/domain/learning_analytics_service.dart';
import 'package:teacher/features/analytics/domain/models/learning_analytics.dart';
import 'package:teacher/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:teacher/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:teacher/features/assessment/domain/models/attempt.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/item_type.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';

Concept _concept(String id, String pathId) => Concept(
  id: id,
  title: 'Concept $id',
  description: '',
  learningPathId: pathId,
  moduleId: 'm-$pathId',
  topicId: 'm-$pathId',
  difficulty: Difficulty.beginner,
  estimatedMinutes: 5,
  prerequisites: const [],
  learningObjectives: const [],
  explanation: const ConceptExplanation(sections: []),
  examples: const [],
  misconceptions: const [],
  exercises: const [],
  assessments: const [],
);

LearningPath _path(String id, List<String> concepts) => LearningPath(
  id: id,
  title: id.toUpperCase(),
  description: '',
  difficulty: Difficulty.beginner,
  iconName: id,
  estimatedHours: 1,
  modules: [
    CurriculumModule(
      learningPathId: id,
      id: 'm-$id',
      title: 'Module',
      order: 0,
      concepts: [for (final c in concepts) _concept(c, id)],
    ),
  ],
);

var _nextId = 0;
Attempt _attempt(String concept, DateTime at, {required bool correct}) =>
    Attempt(
      id: _nextId++,
      conceptId: concept,
      itemId: 'i',
      itemKind: ItemKind.assessment,
      itemType: ItemType.multipleChoice,
      isCorrect: correct,
      selfRating: null,
      hintsUsed: 0,
      userResponse: null,
      createdAt: at,
    );

final _now = DateTime(2026, 10, 22, 21);
final _paths = [
  _path('py', ['a', 'b']),
  _path('js', ['c']),
];

void main() {
  const service = LearningAnalyticsService();

  test('empty history', () {
    final a = service.compute(attempts: const [], paths: _paths, now: _now);
    expect(a.isEmpty, isTrue);
    expect(a.last28Days, hasLength(28));
    expect(a.weekly.every((w) => w.accuracy == null), isTrue);
    expect(a.favouriteDayPart, isNull);
  });

  test('daily, weekly, course, weak spots and day parts', () {
    final attempts = [
      // Today evening: 2 right on a, 1 wrong on b.
      _attempt('a', DateTime(2026, 10, 22, 19), correct: true),
      _attempt('a', DateTime(2026, 10, 22, 20), correct: true),
      _attempt('b', DateTime(2026, 10, 22, 18), correct: false),
      // 10 days ago morning: wrong on b, right on c.
      _attempt('b', DateTime(2026, 10, 12, 9), correct: false),
      _attempt('c', DateTime(2026, 10, 12, 10), correct: true),
      // Older than 28 days: counted in totals, not in the daily series.
      _attempt('c', DateTime(2026, 8, 1, 23), correct: true),
      // Unknown concept: ignored by course/weak breakdowns.
      _attempt('zzz', DateTime(2026, 10, 22, 12), correct: false),
    ];
    final a = service.compute(attempts: attempts, paths: _paths, now: _now);

    expect(a.totalAttempts, 7);
    expect(a.last28Days.last.day, DateTime(2026, 10, 22));
    expect(a.last28Days.last.attempts, 4);
    expect(a.last28Days.last.successes, 2);
    expect(a.activeDaysLast28, 2);

    // This week: 4 answers, 2 right. Two weeks ago window: 2 answers, 1 right.
    expect(a.weekly.last.attempts, 4);
    expect(a.weekly.last.accuracy, 0.5);
    expect(a.weekly[2].attempts, 2);
    expect(a.weekly[2].accuracy, 0.5);
    expect(a.weekly.first.accuracy, isNull);

    expect(a.courses.map((c) => c.learningPathId), ['py', 'js']);
    expect(a.courses.first.attempts, 4);
    expect(a.courses.first.accuracy, 0.5);

    expect(a.weakConcepts.map((w) => w.conceptId), ['b']);
    expect(a.weakConcepts.single.accuracy, 0);

    expect(a.attemptsByDayPart[DayPart.evening], 3);
    expect(a.attemptsByDayPart[DayPart.morning], 2);
    expect(a.attemptsByDayPart[DayPart.night], 1);
    expect(a.favouriteDayPart, DayPart.evening);
  });

  testWidgets('screen shows analytics and an empty state', (tester) async {
    final analytics = service.compute(
      attempts: [
        _attempt('b', DateTime(2026, 10, 22, 9), correct: false),
        _attempt('b', DateTime(2026, 10, 22, 10), correct: true),
      ],
      paths: _paths,
      now: _now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningAnalyticsProvider.overrideWith((ref) async => analytics),
        ],
        child: const MaterialApp(home: AnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Learning Analytics'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Concept b'), 200);
    expect(find.text('Concept b'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          learningAnalyticsProvider.overrideWith(
            (ref) async =>
                service.compute(attempts: const [], paths: _paths, now: _now),
          ),
        ],
        child: const MaterialApp(home: AnalyticsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('analytics will appear here'), findsOneWidget);
  });
}
