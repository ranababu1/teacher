import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/models/roadmap_generation.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/api_key_providers.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/teach_providers.dart';
import 'package:teacher/features/profile/domain/models/learner_profile.dart';
import 'package:teacher/features/profile/presentation/providers/profile_providers.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap_catalog.dart';
import 'package:teacher/features/roadmap/domain/roadmap_repository.dart';
import 'package:teacher/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:teacher/features/roadmap/presentation/screens/roadmap_screen.dart';

class _MemoryRepo implements RoadmapRepository {
  Roadmap? saved;
  @override
  Future<Roadmap?> load() async => saved;
  @override
  Future<void> save(Roadmap roadmap) async => saved = roadmap;
  @override
  Future<void> clear() async => saved = null;
}

class _FailingAi implements AIProvider {
  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) =>
      throw const InvalidAIResponseException('bad');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Profile extends LearnerProfileController {
  @override
  Future<LearnerProfile> build() async => const LearnerProfile(
    name: 'Imran',
    careerGoal: 'Python backend developer',
    hasCompletedOnboarding: true,
  );
}

final _catalog = RoadmapCatalog(
  courses: [
    CatalogCourse(
      id: 'python',
      title: 'Python',
      topics: [
        for (var i = 0; i < 4; i++)
          CatalogEntry(
            kind: RoadmapItemKind.topic,
            id: 'python/p$i',
            title: 'Python topic $i',
            hours: 2,
            pathId: 'python',
            order: i,
          ),
      ],
    ),
  ],
  projects: const [],
  systemDesign: const [],
  challenges: const [],
);

Future<_MemoryRepo> _pump(WidgetTester tester, {bool aiReady = false}) async {
  final repo = _MemoryRepo();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        roadmapRepositoryProvider.overrideWithValue(repo),
        roadmapCatalogProvider.overrideWith((ref) async => _catalog),
        roadmapCompletionProvider.overrideWith(
          (ref) async => const RoadmapCompletion(passedTopicIds: {'python/p0'}),
        ),
        isAiConfiguredProvider.overrideWithValue(aiReady),
        aiProviderProvider.overrideWithValue(_FailingAi()),
        learnerProfileControllerProvider.overrideWith(_Profile.new),
      ],
      child: const MaterialApp(home: RoadmapScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('builds an offline plan from the goal and tracks progress', (
    tester,
  ) async {
    final repo = await _pump(tester);

    // Empty state: the goal form, prefilled from the profile.
    expect(find.text('Python backend developer'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('roadmap-generate-offline')));
    await tester.pumpAndSettle();

    expect(repo.saved, isNotNull);
    expect(find.textContaining('Week 1'), findsOneWidget);
    // The passed topic is skipped; the rest is planned.
    expect(find.text('Python topic 0'), findsNothing);
    expect(find.text('Python topic 1'), findsOneWidget);
    final total = repo.saved!.allItems.length;
    expect(find.text('0 of $total done'), findsOneWidget);
    expect(find.textContaining('Next: Python topic 1'), findsOneWidget);
  });

  testWidgets('items can be removed, and the roadmap deleted', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('roadmap-generate-offline')));
    await tester.pumpAndSettle();
    final before = repo.saved!.allItems.length;

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('roadmap-item-topic:python/p1')),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from roadmap'));
    await tester.pumpAndSettle();
    expect(repo.saved!.allItems.length, before - 1);
    expect(find.text('Python topic 1'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('roadmap-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.saved, isNull);
    expect(find.byKey(const ValueKey('roadmap-goal-field')), findsOneWidget);
  });

  testWidgets('an AI failure offers retry or the offline plan', (tester) async {
    final repo = await _pump(tester, aiReady: true);
    await tester.tap(find.byKey(const ValueKey('roadmap-generate-ai')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('roadmap-retry')), findsOneWidget);
    expect(repo.saved, isNull);

    await tester.tap(find.byKey(const ValueKey('roadmap-use-offline')));
    await tester.pumpAndSettle();
    expect(repo.saved?.source, RoadmapSource.offline);
    expect(find.text('Offline plan', findRichText: false), findsNothing);
    expect(find.textContaining('Offline plan'), findsOneWidget);
  });
}
