import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/roadmap.dart';
import '../domain/roadmap_repository.dart';

/// Keeps the roadmap as one JSON value in the settings key/value table, so
/// no schema migration is needed and it works fully offline.
class RoadmapRepositoryImpl implements RoadmapRepository {
  RoadmapRepositoryImpl(this._db);

  final AppDatabase _db;

  static const storageKey = 'career_roadmap_v1';

  @override
  Future<Roadmap?> load() async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(storageKey))).getSingleOrNull();
    if (row == null) return null;
    try {
      final json = jsonDecode(row.value);
      if (json is! Map<String, dynamic>) return null;
      return Roadmap.fromJson(json);
    } on Object {
      // A corrupt value must not lock the learner out of the feature;
      // they can simply build a new plan.
      return null;
    }
  }

  @override
  Future<void> save(Roadmap roadmap) async {
    try {
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: storageKey,
              value: jsonEncode(roadmap.toJson()),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save roadmap: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await (_db.delete(
        _db.settingsTable,
      )..where((t) => t.key.equals(storageKey))).go();
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to delete roadmap: $e');
    }
  }
}
