import 'package:drift/drift.dart';

/// Detected or authored misconceptions for a concept.
///
/// In v1 (no AI yet) this is populated from authored curriculum content
/// shown proactively in the lesson. Dynamic detection from learner
/// responses is an AI Teacher capability — see instructions.md section 18.
class MisconceptionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get conceptId => text()();
  TextColumn get description => text()();

  DateTimeColumn get detectedAt => dateTime()();
  RealColumn get confidence => real().withDefault(const Constant(1))();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}
