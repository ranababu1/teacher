import 'package:drift/drift.dart';

/// One finished long-form coding challenge with its self-rated score.
class CodingChallengeAttemptsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get challengeId => text()();
  IntColumn get score => integer()();
  IntColumn get maxScore => integer()();
  DateTimeColumn get completedAt => dateTime()();
}
