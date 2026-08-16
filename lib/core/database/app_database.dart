import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/attempts_table.dart';
import 'tables/concept_mastery_table.dart';
import 'tables/learning_path_progress_table.dart';
import 'tables/misconceptions_table.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(learningPathProgressTable);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'teacher_db');
}
