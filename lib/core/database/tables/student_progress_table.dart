import 'package:drift/drift.dart';

/// Tracks whether a learner has started/completed a concept's lesson.
///
/// This is distinct from [ConceptMasteryTable] — progress here means "have
/// they been through the material", not "do they actually understand it".
class StudentProgressTable extends Table {
  TextColumn get conceptId => text()();
  TextColumn get learningPathId => text()();
  TextColumn get moduleId => text()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {conceptId};
}
