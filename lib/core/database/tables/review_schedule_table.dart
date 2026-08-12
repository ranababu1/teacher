import 'package:drift/drift.dart';

/// Spaced-repetition scheduling state for a concept.
///
/// Deliberately simple for v1 — see instructions.md section 23: "Do not
/// implement a complex algorithm prematurely."
class ReviewScheduleTable extends Table {
  TextColumn get conceptId => text()();

  DateTimeColumn get dueAt => dateTime()();
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {conceptId};
}
