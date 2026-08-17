import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/attempts_table.dart';
import 'tables/concept_mastery_table.dart';
import 'tables/learning_path_progress_table.dart';
import 'tables/misconceptions_table.dart';
import 'tables/module_test_progress_table.dart';
import 'tables/review_schedule_table.dart';
import 'tables/settings_table.dart';
import 'tables/student_progress_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    StudentProgressTable,
    ConceptMasteryTable,
    AttemptsTable,
    MisconceptionsTable,
    ReviewScheduleTable,
    SettingsTable,
    LearningPathProgressTable,
    ModuleTestProgressTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(learningPathProgressTable);
        // Backfill: any path with existing concept-level progress from
        // before this migration counts as already started, so upgrading
        // never locks a learner out of a course they were already
        // partway through.
        final existingPathIds =
            await (selectOnly(studentProgressTable)
                  ..addColumns([studentProgressTable.learningPathId])
                  ..groupBy([studentProgressTable.learningPathId]))
                .map((row) => row.read(studentProgressTable.learningPathId))
                .get();
        for (final pathId in existingPathIds.whereType<String>()) {
          await into(learningPathProgressTable).insert(
            LearningPathProgressTableCompanion.insert(
              learningPathId: pathId,
              startedAt: DateTime.now(),
            ),
          );
        }
      }
      if (from < 3) {
        await m.createTable(moduleTestProgressTable);
        // Backfill: any module with existing concept-level progress from
        // before the topic-test gate existed counts as already
        // "passed" (grandfathered), so upgrading never retroactively
        // locks a learner out of a module they were already partway
        // through — same philosophy as the v1->v2 backfill above.
        final existingModules =
            await (selectOnly(studentProgressTable)
                  ..addColumns([
                    studentProgressTable.learningPathId,
                    studentProgressTable.moduleId,
                  ])
                  ..groupBy([
                    studentProgressTable.learningPathId,
                    studentProgressTable.moduleId,
                  ]))
                .get();
        for (final row in existingModules) {
          final pathId = row.read(studentProgressTable.learningPathId);
          final moduleId = row.read(studentProgressTable.moduleId);
          if (pathId == null || moduleId == null) continue;
          await into(moduleTestProgressTable).insert(
            ModuleTestProgressTableCompanion.insert(
              learningPathId: pathId,
              moduleId: moduleId,
              passedAt: DateTime.now(),
              scorePercent: 100,
              questionCount: 0,
              isGrandfathered: const Value(true),
            ),
          );
        }
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'teacher_db');
}
