import 'package:drift/drift.dart';

/// One finished system design walkthrough with its self-rated score.
class SystemDesignAttemptsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text()();
  IntColumn get score => integer()();
  IntColumn get maxScore => integer()();
  DateTimeColumn get completedAt => dateTime()();
}
