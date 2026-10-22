import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/system_design/data/system_design_repository_impl.dart';
import 'package:teacher/features/system_design/domain/models/system_design_exercise.dart';

void main() {
  test('bundled exercises parse with unique ids and full stages', () {
    final json = jsonDecode(
      File(systemDesignAssetPath).readAsStringSync(),
    ) as Map<String, dynamic>;
    final exercises = (json['exercises'] as List<dynamic>)
        .map((e) => SystemDesignExercise.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(exercises.length, greaterThanOrEqualTo(5));
    expect(exercises.map((e) => e.id).toSet(), hasLength(exercises.length));
    for (final e in exercises) {
      expect(e.stages.length, greaterThanOrEqualTo(4), reason: e.id);
      expect(e.maxScore, e.stages.length * 2);
      for (final s in e.stages) {
        expect(
          s.modelAnswer.length,
          greaterThan(80),
          reason: '${e.id}/${s.id}',
        );
        expect(s.hints, isNotEmpty, reason: '${e.id}/${s.id}');
      }
    }
  });

  test('records keep attempt count, best ratio and latest date', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    var now = DateTime(2026, 10, 1);
    final repo = SystemDesignProgressRepositoryImpl(db, clock: () => now);
    await repo.recordAttempt(exerciseId: 'a', score: 4, maxScore: 10);
    now = DateTime(2026, 10, 3);
    await repo.recordAttempt(exerciseId: 'a', score: 8, maxScore: 10);
    now = DateTime(2026, 10, 5);
    await repo.recordAttempt(exerciseId: 'a', score: 6, maxScore: 10);
    await repo.recordAttempt(exerciseId: 'b', score: 10, maxScore: 10);

    final records = await repo.getRecords();
    expect(records['a']!.attempts, 3);
    expect(records['a']!.bestScore, 8);
    expect(records['a']!.bestPercent, 80);
    expect(records['a']!.lastCompletedAt, DateTime(2026, 10, 5));
    expect(records['b']!.bestPercent, 100);
    expect(records.containsKey('c'), isFalse);
  });

  test(
    'upgrading a v3 database adds the project, design and challenge tables',
    () async {
      final dir = Directory.systemTemp.createTempSync('teacher_db');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/app.sqlite');

      // Build a current database, then roll it back to look like v3.
      var db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customSelect('SELECT 1').get();
      await db.customStatement('DROP TABLE project_milestone_progress_table');
      await db.customStatement('DROP TABLE system_design_attempts_table');
      await db.customStatement('DROP TABLE coding_challenge_attempts_table');
      await db.customStatement('PRAGMA user_version = 3');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      await SystemDesignProgressRepositoryImpl(db)
          .recordAttempt(exerciseId: 'x', score: 1, maxScore: 2);
      expect(
        (await db.select(db.systemDesignAttemptsTable).get()),
        hasLength(1),
      );
      expect(await db.select(db.projectMilestoneProgressTable).get(), isEmpty);
      expect(await db.select(db.codingChallengeAttemptsTable).get(), isEmpty);
    },
  );
}
