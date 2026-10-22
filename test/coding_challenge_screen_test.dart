import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/features/coding_challenges/domain/coding_challenge_repository.dart';
import 'package:teacher/features/coding_challenges/domain/models/coding_challenge.dart';
import 'package:teacher/features/coding_challenges/presentation/providers/coding_challenge_providers.dart';
import 'package:teacher/features/coding_challenges/presentation/screens/coding_challenge_list_screen.dart';
import 'package:teacher/features/coding_challenges/presentation/screens/coding_challenge_screen.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/presentation/curriculum_providers.dart';

const _challenge = LongFormChallenge(
  id: 'lru',
  learningPathId: 'go',
  language: 'go',
  title: 'LRU cache',
  difficulty: Difficulty.intermediate,
  estimatedMinutes: 40,
  summary: 'Build one.',
  statement: 'Build an LRU cache.',
  starterCode: 'package lru',
  parts: [
    ChallengePart(
      id: 'p1',
      title: 'Get and Put',
      task: 'Implement Get and Put.',
      hints: ['Use a map.'],
      checks: ['Get on a missing key returns false'],
      solution: 'func (c *Cache) Get() {}',
      explanation: 'Map plus list.',
    ),
    ChallengePart(
      id: 'p2',
      title: 'Evict',
      task: 'Evict the oldest.',
      hints: ['Back of the list.'],
      checks: ['Capacity is respected'],
      solution: 'func (c *Cache) Put() {}',
      explanation: 'Remove the back.',
    ),
  ],
);

class _FakeRepo implements CodingChallengeRepository {
  _FakeRepo(this.items);
  final List<LongFormChallenge> items;
  @override
  Future<List<LongFormChallenge>> getChallenges() async => items;
  @override
  Future<LongFormChallenge?> getChallenge(String id) async =>
      items.where((c) => c.id == id).firstOrNull;
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget app(
    Widget home, [
    List<LongFormChallenge> items = const [_challenge],
  ]) => ProviderScope(
    key: UniqueKey(),
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      codingChallengeRepositoryProvider.overrideWithValue(_FakeRepo(items)),
      learningPathsProvider.overrideWith((ref) async => const []),
    ],
    child: MaterialApp(home: home),
  );

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.dragUntilVisible(
      find.text(text),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('parts flow keeps code, reveals solution, saves score', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const CodingChallengeScreen(challengeId: 'lru')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Part 1 of 2 · Get and Put'), findsOneWidget);
    expect(find.text('package lru'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('code-editor')),
      'package lru\n// mine',
    );
    await tapText(tester, 'Show a hint');
    expect(find.text('Use a map.'), findsOneWidget);
    await tapText(tester, 'Get on a missing key returns false');
    await tapText(tester, 'Reveal Reference Solution');
    await tester.dragUntilVisible(
      find.text('Map plus list.'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    expect(find.text('Map plus list.'), findsOneWidget);
    await tapText(tester, 'Nailed it');

    expect(find.text('Part 2 of 2 · Evict'), findsOneWidget);
    expect(find.text('package lru\n// mine'), findsOneWidget);
    await tapText(tester, 'Reveal Reference Solution');
    await tapText(tester, 'Missed it');

    expect(find.text('Challenge score: 50%'), findsOneWidget);
    expect(find.text('Parts to revisit'), findsOneWidget);
    final rows = await db.select(db.codingChallengeAttemptsTable).get();
    expect(rows.single.score, 2);
    expect(rows.single.maxScore, 4);
  });

  testWidgets('unknown challenge shows empty state', (tester) async {
    await tester.pumpWidget(app(const CodingChallengeScreen(challengeId: 'x')));
    await tester.pumpAndSettle();
    expect(find.text("We couldn't find that challenge."), findsOneWidget);
  });

  testWidgets('list shows parts and best score; empty state', (tester) async {
    await db
        .into(db.codingChallengeAttemptsTable)
        .insert(
          CodingChallengeAttemptsTableCompanion.insert(
            challengeId: 'lru',
            score: 3,
            maxScore: 4,
            completedAt: DateTime(2026),
          ),
        );
    await tester.pumpWidget(app(const CodingChallengeListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('LRU cache'), findsOneWidget);
    expect(find.textContaining('2 parts'), findsOneWidget);
    expect(find.textContaining('Best 75%'), findsOneWidget);

    await tester.pumpWidget(app(const CodingChallengeListScreen(), const []));
    await tester.pumpAndSettle();
    expect(find.text('No long-form challenges yet.'), findsOneWidget);
  });
}
