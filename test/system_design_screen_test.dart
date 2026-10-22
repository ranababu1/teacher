import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/system_design/domain/models/system_design_exercise.dart';
import 'package:teacher/features/system_design/domain/system_design_repository.dart';
import 'package:teacher/features/system_design/presentation/providers/system_design_providers.dart';
import 'package:teacher/features/system_design/presentation/screens/system_design_exercise_screen.dart';
import 'package:teacher/features/system_design/presentation/screens/system_design_list_screen.dart';

const _exercise = SystemDesignExercise(
  id: 'rl',
  title: 'Rate limiter',
  difficulty: Difficulty.intermediate,
  estimatedMinutes: 30,
  summary: 'Limit requests.',
  scenario: 'Many gateways.',
  stages: [
    DesignStage(
      id: 's1',
      title: 'Clarify requirements',
      prompt: 'What do you ask?',
      hints: ['Who is limited?', 'Exact or approximate?'],
      modelAnswer: 'Per key limits.',
    ),
    DesignStage(
      id: 's2',
      title: 'Estimate scale',
      prompt: 'How big?',
      hints: ['Keys?'],
      modelAnswer: 'About 1M keys.',
    ),
  ],
  commonPitfalls: ['Local counters per gateway.'],
);

class _FakeRepo implements SystemDesignRepository {
  _FakeRepo(this.items);
  final List<SystemDesignExercise> items;
  @override
  Future<List<SystemDesignExercise>> getExercises() async => items;
  @override
  Future<SystemDesignExercise?> getExercise(String id) async =>
      items.where((e) => e.id == id).firstOrNull;
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(
    Widget home, {
    List<SystemDesignExercise> items = const [_exercise],
  }) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      systemDesignRepositoryProvider.overrideWithValue(_FakeRepo(items)),
    ],
    child: MaterialApp(home: home),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('walkthrough: hints, reveal, rate, summary saves attempt', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const SystemDesignExerciseScreen(exerciseId: 'rl')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stage 1 of 2 · Clarify requirements'), findsOneWidget);
    expect(find.text('Who is limited?'), findsNothing);

    await tapText(tester, 'Show a hint');
    expect(find.text('Who is limited?'), findsOneWidget);
    await tapText(tester, 'Another hint');
    expect(find.text('Exact or approximate?'), findsOneWidget);
    expect(find.text('Another hint'), findsNothing);

    await tapText(tester, 'Reveal Model Answer');
    expect(find.text('Per key limits.'), findsOneWidget);
    await tapText(tester, 'Nailed it');

    expect(find.text('Stage 2 of 2 · Estimate scale'), findsOneWidget);
    await tapText(tester, 'Reveal Model Answer');
    await tapText(tester, 'Partly');

    expect(find.text('Design score: 75%'), findsOneWidget);
    expect(find.text('Stages to revisit'), findsOneWidget);
    expect(find.text('Local counters per gateway.'), findsOneWidget);

    final rows = await db.select(db.systemDesignAttemptsTable).get();
    expect(rows.single.score, 3);
    expect(rows.single.maxScore, 4);

    await tapText(tester, 'Try Again');
    expect(find.text('Stage 1 of 2 · Clarify requirements'), findsOneWidget);
  });

  testWidgets('unknown exercise shows empty state', (tester) async {
    await tester.pumpWidget(
      app(const SystemDesignExerciseScreen(exerciseId: 'nope')),
    );
    await tester.pumpAndSettle();
    expect(find.text("We couldn't find that exercise."), findsOneWidget);
  });

  testWidgets('list shows best score after an attempt; empty state', (
    tester,
  ) async {
    await db
        .into(db.systemDesignAttemptsTable)
        .insert(
          SystemDesignAttemptsTableCompanion.insert(
            exerciseId: 'rl',
            score: 2,
            maxScore: 4,
            completedAt: DateTime(2026),
          ),
        );
    await tester.pumpWidget(app(const SystemDesignListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Rate limiter'), findsOneWidget);
    expect(find.textContaining('Best 50% (1x)'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          systemDesignRepositoryProvider.overrideWithValue(_FakeRepo(const [])),
        ],
        child: const MaterialApp(home: SystemDesignListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No system design exercises yet.'), findsOneWidget);
  });
}
