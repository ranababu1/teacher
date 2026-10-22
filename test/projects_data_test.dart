import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/projects/data/project_repository_impl.dart';
import 'package:teacher/features/projects/domain/models/project.dart';

void main() {
  group('bundled projects content', () {
    final projects =
        ((jsonDecode(File(projectsAssetPath).readAsStringSync())
                    as Map<String, dynamic>)['projects']
                as List<dynamic>)
            .map((p) => Project.fromJson(p as Map<String, dynamic>))
            .toList();
    final manifest = jsonDecode(
      File('assets/curriculum/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final moduleIdsByPath = <String, Set<String>>{
      for (final p in manifest['learningPaths'] as List<dynamic>)
        p['id'] as String: {
          for (final f in p['moduleFiles'] as List<dynamic>)
            (jsonDecode(File('assets/curriculum/$f').readAsStringSync())
                    as Map<String, dynamic>)['moduleId']
                as String,
        },
    };

    test('parses, with unique ids and at least 3 milestones each', () {
      expect(projects, isNotEmpty);
      expect(projects.map((p) => p.id).toSet(), hasLength(projects.length));
      for (final p in projects) {
        expect(p.milestones.length, greaterThanOrEqualTo(3), reason: p.id);
        expect(
          p.milestones.map((m) => m.id).toSet(),
          hasLength(p.milestones.length),
          reason: p.id,
        );
        expect(p.rubric, isNotEmpty, reason: p.id);
      }
    });

    test('every project points at a real course and topic', () {
      for (final p in projects) {
        expect(moduleIdsByPath.keys, contains(p.learningPathId), reason: p.id);
        if (p.recommendedAfterModuleId != null) {
          expect(
            moduleIdsByPath[p.learningPathId],
            contains(p.recommendedAfterModuleId),
            reason: p.id,
          );
        }
      }
    });
  });

  group('ProjectProgressRepositoryImpl', () {
    late AppDatabase db;
    late ProjectProgressRepositoryImpl repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ProjectProgressRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('tick, untick and list milestones per project', () async {
      await repo.setMilestoneCompleted(
        projectId: 'p1',
        milestoneId: 'm1',
        completed: true,
      );
      await repo.setMilestoneCompleted(
        projectId: 'p1',
        milestoneId: 'm2',
        completed: true,
      );
      await repo.setMilestoneCompleted(
        projectId: 'p2',
        milestoneId: 'm1',
        completed: true,
      );
      // Idempotent.
      await repo.setMilestoneCompleted(
        projectId: 'p1',
        milestoneId: 'm1',
        completed: true,
      );
      expect(await repo.getCompletedMilestones('p1'), {'m1', 'm2'});

      await repo.setMilestoneCompleted(
        projectId: 'p1',
        milestoneId: 'm1',
        completed: false,
      );
      expect(await repo.getAllCompletedMilestones(), {
        'p1': {'m2'},
        'p2': {'m1'},
      });
    });
  });
}
