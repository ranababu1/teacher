import 'package:drift/drift.dart';

/// Tracks whether a learner has passed a module's ("topic's") gating
/// test — the hard gate that must be satisfied before the next module in
/// a path can be opened. Keyed by (learningPathId, moduleId), not
/// moduleId alone, since module ids are reused across paths.
class ModuleTestProgressTable extends Table {
  TextColumn get learningPathId => text()();
  TextColumn get moduleId => text()();
  DateTimeColumn get passedAt => dateTime()();
  IntColumn get scorePercent => integer()();
  IntColumn get questionCount => integer()();

  /// True for rows backfilled during the v2->v3 migration for learners
  /// who had already started a module under the old, gate-free rules —
  /// never a real test attempt. Kept as a real column (not inferred)
  /// so this decision stays introspectable/reversible later.
  BoolColumn get isGrandfathered =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {learningPathId, moduleId};
}
