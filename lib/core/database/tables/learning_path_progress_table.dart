import 'package:drift/drift.dart';

/// Tracks whether a learner has explicitly "Started" a learning path
/// (course) — the hard gate that must be satisfied before any of its
/// lessons can be opened. A row's mere existence means started; distinct
/// from [StudentProgressTable], which tracks per-concept lesson progress
/// inside an already-started path.
class LearningPathProgressTable extends Table {
  TextColumn get learningPathId => text()();
  DateTimeColumn get startedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {learningPathId};
}
