import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/data/shared_prompt_builder.dart'
    as shared;
import 'package:teacher/features/settings/domain/settings_models.dart';
import 'package:teacher/features/ai_teacher/domain/models/roadmap_generation.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap.dart';
import 'package:teacher/features/roadmap/domain/models/roadmap_catalog.dart';
import 'package:teacher/features/roadmap/domain/offline_roadmap_builder.dart';
import 'package:teacher/features/roadmap/domain/roadmap_progress.dart';
import 'package:teacher/features/roadmap/domain/roadmap_validator.dart';

CatalogEntry _topic(String path, String module, int order) => CatalogEntry(
  kind: RoadmapItemKind.topic,
  id: '$path/$module',
  title: '$path $module',
  hours: 2,
  pathId: path,
  order: order,
);

final _catalog = RoadmapCatalog(
  courses: [
    CatalogCourse(
      id: 'python',
      title: 'Python',
      topics: [for (var i = 0; i < 6; i++) _topic('python', 'p$i', i)],
    ),
    CatalogCourse(
      id: 'databases',
      title: 'Databases',
      topics: [for (var i = 0; i < 3; i++) _topic('databases', 'd$i', i)],
    ),
    CatalogCourse(
      id: 'system-design',
      title: 'System Design',
      topics: [_topic('system-design', 's0', 0)],
    ),
    CatalogCourse(
      id: 'react',
      title: 'React',
      topics: [_topic('react', 'r0', 0)],
    ),
  ],
  projects: const [
    CatalogEntry(
      kind: RoadmapItemKind.project,
      id: 'py-proj',
      title: 'Python project',
      hours: 6,
      pathId: 'python',
      afterModuleId: 'p2',
    ),
  ],
  systemDesign: const [
    CatalogEntry(
      kind: RoadmapItemKind.systemDesign,
      id: 'url',
      title: 'URL shortener',
      hours: 1,
    ),
    CatalogEntry(
      kind: RoadmapItemKind.systemDesign,
      id: 'feed',
      title: 'News feed',
      hours: 1,
      difficulty: 'advanced',
    ),
  ],
  challenges: const [
    CatalogEntry(
      kind: RoadmapItemKind.challenge,
      id: 'py-ch',
      title: 'Python challenge',
      hours: 1,
      pathId: 'python',
    ),
  ],
);

const _goal = RoadmapGoal(
  goal: 'Backend developer job',
  level: RoadmapLevel.beginner,
  hoursPerWeek: 6,
  weeks: 4,
);

final _now = DateTime(2026, 10, 23);

void main() {
  group('Roadmap model', () {
    final roadmap = Roadmap(
      goal: _goal,
      summary: 's',
      source: RoadmapSource.ai,
      createdAt: _now,
      weeks: const [
        RoadmapWeek(
          focus: 'A',
          items: [
            RoadmapItem(
              kind: RoadmapItemKind.topic,
              refId: 'python/p0',
              title: 'P0',
            ),
            RoadmapItem(
              kind: RoadmapItemKind.project,
              refId: 'py-proj',
              title: 'Proj',
            ),
          ],
        ),
        RoadmapWeek(focus: 'B', items: []),
      ],
    );

    test('round-trips through JSON', () {
      expect(Roadmap.fromJson(roadmap.toJson()), roadmap);
    });

    test('drops unknown item kinds when reading', () {
      final json = roadmap.toJson();
      ((json['weeks'] as List).first as Map)['items'] = [
        {'kind': 'video', 'refId': 'x'},
        {'kind': 'topic', 'refId': 'python/p1', 'title': 'P1'},
      ];
      expect(Roadmap.fromJson(json).allItems.single.refId, 'python/p1');
    });

    test('goal values are clamped', () {
      final g = RoadmapGoal.fromJson(const {
        'goal': ' x ',
        'hoursPerWeek': 500,
        'weeks': 0,
      });
      expect(g.goal, 'x');
      expect(g.hoursPerWeek, RoadmapGoal.maxHours);
      expect(g.weeks, RoadmapGoal.minWeeks);
    });

    test('remove and move items between weeks', () {
      final removed = roadmap.removeItem('topic:python/p0');
      expect(removed.allItems.map((i) => i.refId), ['py-proj']);
      expect(removed.weeks, hasLength(2));

      final moved = roadmap.moveItem('project:py-proj', 1);
      expect(moved.weeks[0].items.map((i) => i.refId), ['python/p0']);
      expect(moved.weeks[1].items.map((i) => i.refId), ['py-proj']);
      expect(
        moved.moveItem('project:py-proj', -1).weeks[0].items.last.refId,
        'py-proj',
      );
      expect(roadmap.moveItem('topic:python/p0', -1), roadmap);
    });
  });

  group('RoadmapValidator', () {
    const validator = RoadmapValidator();

    test('keeps only real content, with catalog titles, no duplicates', () {
      const draft = RoadmapDraft(
        summary: 'Plan',
        weeks: [
          RoadmapDraftWeek(
            focus: 'Basics',
            items: [
              RoadmapDraftItem(kind: 'topic', id: 'python/p0', note: 'n'),
              RoadmapDraftItem(kind: 'topic', id: 'python/made-up'),
              RoadmapDraftItem(kind: 'course', id: 'python'),
              RoadmapDraftItem(kind: 'project', id: 'py-proj'),
            ],
          ),
          RoadmapDraftWeek(
            focus: '',
            items: [RoadmapDraftItem(kind: 'topic', id: 'python/p0')],
          ),
        ],
      );
      final result = validator.validate(
        draft: draft,
        catalog: _catalog,
        goal: _goal,
        now: _now,
      );
      expect(result.droppedItems, 3);
      expect(result.roadmap.source, RoadmapSource.ai);
      expect(result.roadmap.weeks[0].items.map((i) => i.title), [
        'python p0',
        'Python project',
      ]);
      expect(result.roadmap.weeks[1].focus, 'Week 2');
      expect(result.roadmap.weeks[1].items, isEmpty);
    });

    test('cuts weeks beyond the goal', () {
      final draft = RoadmapDraft(
        summary: '',
        weeks: [
          for (var i = 0; i < 6; i++)
            RoadmapDraftWeek(
              focus: 'w$i',
              items: [RoadmapDraftItem(kind: 'topic', id: 'python/p$i')],
            ),
        ],
      );
      final result = validator.validate(
        draft: draft,
        catalog: _catalog,
        goal: _goal,
        now: _now,
      );
      expect(result.roadmap.weeks, hasLength(4));
      expect(result.droppedItems, 2);
    });

    test('a plan with nothing real is rejected', () {
      expect(
        () => validator.validate(
          draft: const RoadmapDraft(
            summary: '',
            weeks: [
              RoadmapDraftWeek(
                focus: 'x',
                items: [RoadmapDraftItem(kind: 'topic', id: 'nope/nope')],
              ),
            ],
          ),
          catalog: _catalog,
          goal: _goal,
          now: _now,
        ),
        throwsA(isA<InvalidAIResponseException>()),
      );
    });
  });

  group('OfflineRoadmapBuilder', () {
    const builder = OfflineRoadmapBuilder();

    test('maps goals to courses that exist', () {
      expect(builder.chooseCourses('Backend developer job', _catalog), [
        'python',
        'databases',
        'system-design',
      ]);
      expect(builder.chooseCourses('learn React', _catalog), ['react']);
      expect(builder.chooseCourses('something vague', _catalog), [
        'python',
        'databases',
      ]);
    });

    test('builds a valid plan within the weekly hours', () {
      final roadmap = builder.build(
        goal: _goal,
        catalog: _catalog,
        completion: const RoadmapCompletion(),
        now: _now,
      );
      expect(roadmap.source, RoadmapSource.offline);
      expect(roadmap.weeks, hasLength(4));
      for (final item in roadmap.allItems) {
        expect(_catalog.lookup(item.kind, item.refId), isNotNull);
      }
      final first = roadmap.weeks.first.items.map((i) => i.refId).toList();
      expect(first, ['python/p0', 'python/p1', 'python/p2']);
      // The project follows the topic it is recommended after.
      expect(roadmap.weeks[1].items.first.refId, 'py-proj');
    });

    test('skips passed topics and early topics for experienced learners', () {
      final roadmap = builder.build(
        goal: const RoadmapGoal(
          goal: 'python',
          level: RoadmapLevel.advanced,
          hoursPerWeek: 30,
          weeks: 1,
        ),
        catalog: _catalog,
        completion: const RoadmapCompletion(passedTopicIds: {'python/p4'}),
        now: _now,
      );
      expect(roadmap.allItems.map((i) => i.refId), [
        'python/p3',
        'python/p5',
        'py-ch',
      ]);
    });

    test('beginners do not get advanced design exercises', () {
      final roadmap = builder.build(
        goal: const RoadmapGoal(
          goal: 'system design',
          level: RoadmapLevel.beginner,
          hoursPerWeek: 30,
          weeks: 2,
        ),
        catalog: _catalog,
        completion: const RoadmapCompletion(),
        now: _now,
      );
      final ids = roadmap.allItems.map((i) => i.refId);
      expect(ids, contains('url'));
      expect(ids, isNot(contains('feed')));
    });
  });

  test('progress comes from completion data', () {
    final roadmap = const OfflineRoadmapBuilder().build(
      goal: _goal,
      catalog: _catalog,
      completion: const RoadmapCompletion(),
      now: _now,
    );
    final progress = RoadmapProgress(
      roadmap,
      const RoadmapCompletion(
        passedTopicIds: {'python/p0'},
        completedProjectIds: {'py-proj'},
      ),
    );
    expect(progress.done, 2);
    expect(progress.total, roadmap.allItems.length);
    expect(progress.next!.refId, 'python/p1');
    expect(progress.doneInWeek(roadmap.weeks.first), 1);
  });

  test('the AI prompt carries the catalog and the hard constraints', () {
    final prompt = shared.buildGenerateRoadmapPrompt(
      RoadmapGenerationRequest(
        goal: 'Backend job',
        level: 'beginner',
        hoursPerWeek: 6,
        weeks: 4,
        catalog: _catalog.toPromptText(),
      ),
      depth: ExplanationDepth.values.first,
      outputInstruction: 'JSON',
    );
    expect(prompt.userContent, contains('python/p0'));
    expect(prompt.userContent, contains('py-proj'));
    expect(prompt.userContent, contains('exactly 4 weeks'));
    expect(prompt.userContent, contains('Never invent ids'));
    expect(prompt.systemInstruction, contains('JSON'));
  });
}
