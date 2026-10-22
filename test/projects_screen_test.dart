import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/features/curriculum/domain/models/curriculum_module.dart';
import 'package:teacher/features/curriculum/domain/models/difficulty.dart';
import 'package:teacher/features/curriculum/domain/models/learning_path.dart';
import 'package:teacher/features/curriculum/presentation/curriculum_providers.dart';
import 'package:teacher/features/progress/presentation/providers/progress_providers.dart';
import 'package:teacher/features/projects/domain/models/project.dart';
import 'package:teacher/features/projects/domain/project_repository.dart';
import 'package:teacher/features/projects/presentation/providers/project_providers.dart';
import 'package:teacher/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:teacher/features/projects/presentation/screens/projects_screen.dart';

Project _project(String id, {String? after}) => Project(
  id: id,
  learningPathId: 'py',
  title: 'Project $id',
  summary: 'Summary $id',
  brief: '## Brief $id',
  difficulty: Difficulty.beginner,
  estimatedHours: 3,
  skills: const ['files'],
  milestones: const [
    ProjectMilestone(id: 'm1', title: 'First', description: 'Do one'),
    ProjectMilestone(id: 'm2', title: 'Second', description: 'Do two'),
  ],
  rubric: const [RubricCriterion(criterion: 'Clean code', lookFor: 'Names')],
  stretchGoals: const ['Add tests'],
  recommendedAfterModuleId: after,
);

class _FakeProjects implements ProjectRepository {
  _FakeProjects(this.projects);
  final List<Project> projects;
  @override
  Future<List<Project>> getProjects() async => projects;
  @override
  Future<Project?> getProject(String projectId) async =>
      projects.where((p) => p.id == projectId).firstOrNull;
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
      id: 'basics',
      title: 'Basics',
      order: 0,
      concepts: [],
    ),
    CurriculumModule(
      learningPathId: 'py',
      id: 'files',
      title: 'Files',
      order: 1,
      concepts: [],
    ),
  ],
);

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  List<Override> overrides(List<Project> projects) => [
    appDatabaseProvider.overrideWithValue(db),
    projectRepositoryProvider.overrideWithValue(_FakeProjects(projects)),
    learningPathProvider.overrideWith((ref, id) async => _path),
    passedModuleIdsProvider.overrideWith((ref, id) async => {'basics'}),
  ];

  testWidgets('detail: tick milestones, progress persists, completion card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides([_project('a', after: 'files')]),
        child: const MaterialApp(home: ProjectDetailScreen(projectId: 'a')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Best after passing the "Files"'), findsOne);
    expect(find.text('0/2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('milestone-m1')));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('milestone-m2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('milestone-m2')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('All milestones done'));
    expect(find.textContaining('All milestones done'), findsOneWidget);

    final stored = await db.select(db.projectMilestoneProgressTable).get();
    expect(stored.map((r) => r.milestoneId).toSet(), {'m1', 'm2'});
  });

  testWidgets('detail: unknown project shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides([_project('a')]),
        child: const MaterialApp(home: ProjectDetailScreen(projectId: 'zzz')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("We couldn't find that project."), findsOneWidget);
  });

  testWidgets('list: readiness labels, in-progress first', (tester) async {
    await db
        .into(db.projectMilestoneProgressTable)
        .insert(
          ProjectMilestoneProgressTableCompanion.insert(
            projectId: 'c',
            milestoneId: 'm1',
            completedAt: DateTime(2026),
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides([
          _project('a', after: 'files'),
          _project('b', after: 'basics'),
          _project('c'),
        ]),
        child: const MaterialApp(home: ProjectsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1/2 milestones'), findsOneWidget);
    expect(find.text('Ready to start'), findsOneWidget);
    expect(find.text('Best after "Files"'), findsOneWidget);

    final order = [
      for (final id in ['c', 'b', 'a'])
        tester.getTopLeft(find.byKey(ValueKey('project-$id'))).dy,
    ];
    expect(order, orderedEquals([...order]..sort()));
  });

  testWidgets('list: empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(const []),
        child: const MaterialApp(home: ProjectsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No projects are available yet.'), findsOneWidget);
  });
}
