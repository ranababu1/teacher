import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/learning_path_progress_repository.dart';

class LearningPathProgressRepositoryImpl
    implements LearningPathProgressRepository {
  LearningPathProgressRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<Set<String>> getStartedPathIds() async {
    final rows = await _db.select(_db.learningPathProgressTable).get();
    return rows.map((r) => r.learningPathId).toSet();
  }

  @override
  Future<bool> isPathStarted(String learningPathId) async {
    final row = await (_db.select(
      _db.learningPathProgressTable,
    )..where((t) => t.learningPathId.equals(learningPathId))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> markPathStarted(String learningPathId) async {
    if (await isPathStarted(learningPathId)) return;

    try {
      await _db
          .into(_db.learningPathProgressTable)
          .insertOnConflictUpdate(
            LearningPathProgressTableCompanion.insert(
              learningPathId: learningPathId,
              startedAt: DateTime.now(),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException(
        'Failed to mark path $learningPathId started: $e',
      );
    }
  }
}
