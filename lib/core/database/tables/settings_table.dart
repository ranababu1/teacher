import 'package:drift/drift.dart';

/// Generic key-value store for application settings.
///
/// A typed [SettingsRepository] sits in front of this table so callers
/// never deal with raw string keys — see features/settings/data.
class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
