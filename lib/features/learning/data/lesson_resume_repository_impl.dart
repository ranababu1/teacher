import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/lesson_resume_repository.dart';

/// Stores the last viewed step per concept in the settings key/value table
/// (key `lesson_step_<conceptId>`), so no schema migration is needed.
class LessonResumeRepositoryImpl implements LessonResumeRepository {
  LessonResumeRepositoryImpl(this._db);

  final AppDatabase _db;

  static String keyFor(String conceptId) => 'lesson_step_$conceptId';

  @override
  Future<String?> lastStepId(String conceptId) async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(keyFor(conceptId)))).getSingleOrNull();
    final value = row?.value;
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<void> saveStep(String conceptId, String stepId) async {
    try {
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: keyFor(conceptId),
              value: stepId,
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save lesson step: $e');
    }
  }

  @override
  Future<void> clear(String conceptId) async {
    try {
      await (_db.delete(
        _db.settingsTable,
      )..where((t) => t.key.equals(keyFor(conceptId)))).go();
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to clear lesson step: $e');
    }
  }
}
