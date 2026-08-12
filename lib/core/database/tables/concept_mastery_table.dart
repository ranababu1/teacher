import 'package:drift/drift.dart';

/// Evidence-based mastery tracking for a single concept.
///
/// Deliberately multi-dimensional — see instructions.md section 15. Mastery
/// is never a single simplistic percentage.
class ConceptMasteryTable extends Table {
  TextColumn get conceptId => text()();

  RealColumn get recallScore => real().withDefault(const Constant(0))();
  RealColumn get understandingScore => real().withDefault(const Constant(0))();
  RealColumn get applicationScore => real().withDefault(const Constant(0))();
  RealColumn get explanationScore => real().withDefault(const Constant(0))();
  RealColumn get codingScore => real().withDefault(const Constant(0))();
  RealColumn get debuggingScore => real().withDefault(const Constant(0))();

  RealColumn get overallMastery => real().withDefault(const Constant(0))();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get successCount => integer().withDefault(const Constant(0))();
  IntColumn get failureCount => integer().withDefault(const Constant(0))();

  RealColumn get confidence => real().withDefault(const Constant(0))();

  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  /// One of: not_started, learning, developing, proficient, mastered, needs_review
  TextColumn get status => text().withDefault(const Constant('not_started'))();

  @override
  Set<Column> get primaryKey => {conceptId};
}
