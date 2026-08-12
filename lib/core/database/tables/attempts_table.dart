import 'package:drift/drift.dart';

/// A single learner attempt at an exercise or assessment item.
///
/// This is the raw evidence that mastery calculations and review scheduling
/// are derived from — see instructions.md sections 15 and 23.
class AttemptsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get conceptId => text()();
  TextColumn get itemId => text()();

  /// "exercise" or "assessment"
  TextColumn get itemKind => text()();

  /// Matches ItemType: multipleChoice, shortAnswer, predictOutput,
  /// debugging, coding, explanation, scenario.
  TextColumn get itemType => text()();

  /// Null when the item isn't auto-gradable and hasn't been self-rated yet.
  BoolColumn get isCorrect => boolean().nullable()();

  /// Self-rating on a 1-4 scale (Again/Hard/Good/Easy) for ungraded items.
  IntColumn get selfRating => integer().nullable()();

  IntColumn get hintsUsed => integer().withDefault(const Constant(0))();

  TextColumn get userResponse => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
