import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/models/roadmap_generation.dart';
import 'package:teacher/features/roadmap/data/roadmap_repository_impl.dart';
import 'package:teacher/features/roadmap/domain/generate_roadmap_use_case.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap_catalog.dart';

class _FakeAi implements AIProvider {
  _FakeAi({this.draft, this.error});
  final RoadmapDraft? draft;
  final Object? error;
  RoadmapGenerationRequest? lastRequest;

  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;
    return draft!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
            title: 'Topic $i',
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

const _goal = RoadmapGoal(
  goal: 'Python job',
  level: RoadmapLevel.beginner,
  hoursPerWeek: 4,
  weeks: 2,
);

void main() {
  group('GenerateRoadmapUseCase', () {
    test('uses the AI plan, validated against the catalog', () async {
      final ai = _FakeAi(
        draft: const RoadmapDraft(
          summary: 'Two weeks of Python.',
          weeks: [
            RoadmapDraftWeek(
              focus: 'Start',
              items: [
                RoadmapDraftItem(kind: 'topic', id: 'python/p1'),
                RoadmapDraftItem(kind: 'topic', id: 'python/ghost'),
              ],
            ),
          ],
        ),
      );
      final result = await GenerateRoadmapUseCase(aiProvider: ai).generate(
        goal: _goal,
        catalog: _catalog,
        completion: const RoadmapCompletion(passedTopicIds: {'python/p0'}),
      );
      expect(result.fellBackOffline, isFalse);
      expect(result.droppedItems, 1);
      expect(result.roadmap.source, RoadmapSource.ai);
      expect(result.roadmap.allItems.single.title, 'Topic 1');
      expect(ai.lastRequest!.catalog, contains('python/p3'));
      expect(ai.lastRequest!.learnerSummary, contains('python/p0'));
      expect(ai.lastRequest!.weeks, 2);
    });

    for (final error in [
      const AIUnavailableException(),
      const NetworkUnavailableException(),
    ]) {
      test('falls back offline on ${error.runtimeType}', () async {
        final result =
            await GenerateRoadmapUseCase(aiProvider: _FakeAi(error: error))
                .generate(
                  goal: _goal,
                  catalog: _catalog,
                  completion: const RoadmapCompletion(),
                );
        expect(result.fellBackOffline, isTrue);
        expect(result.roadmap.source, RoadmapSource.offline);
        expect(result.roadmap.allItems, isNotEmpty);
      });
    }

    test('other AI failures are surfaced, not hidden', () async {
      await expectLater(
        GenerateRoadmapUseCase(
          aiProvider: _FakeAi(error: const InvalidAIResponseException('bad')),
        ).generate(
          goal: _goal,
          catalog: _catalog,
          completion: const RoadmapCompletion(),
        ),
        throwsA(isA<InvalidAIResponseException>()),
      );
    });

    test('an empty catalog is an error, not an empty plan', () {
      expect(
        () => GenerateRoadmapUseCase(aiProvider: _FakeAi()).buildOffline(
          goal: _goal,
          catalog: RoadmapCatalog(
            courses: const [],
            projects: const [],
            systemDesign: const [],
            challenges: const [],
          ),
          completion: const RoadmapCompletion(),
        ),
        throwsA(isA<ContentNotFoundException>()),
      );
    });
  });

  group('RoadmapRepositoryImpl', () {
    late AppDatabase db;
    late RoadmapRepositoryImpl repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = RoadmapRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('saves, loads and clears the roadmap', () async {
      expect(await repo.load(), isNull);
      final roadmap = GenerateRoadmapUseCase(aiProvider: _FakeAi())
          .buildOffline(
            goal: _goal,
            catalog: _catalog,
            completion: const RoadmapCompletion(),
            now: DateTime(2026, 10, 23),
          );
      await repo.save(roadmap);
      expect(await repo.load(), roadmap);
      await repo.clear();
      expect(await repo.load(), isNull);
    });

    test('a corrupt saved value reads as no roadmap', () async {
      await db
          .into(db.settingsTable)
          .insert(
            SettingsTableCompanion.insert(
              key: RoadmapRepositoryImpl.storageKey,
              value: '{not json',
            ),
          );
      expect(await repo.load(), isNull);
    });
  });
}
