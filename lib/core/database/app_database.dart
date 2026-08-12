import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/attempts_table.dart';
import 'tables/concept_mastery_table.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'teacher_db');
}
