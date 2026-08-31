import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/module_test_progress_repository.dart';

class ModuleTestProgressRepositoryImpl
    implements ModuleTestProgressRepository {
  ModuleTestProgressRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<Set<String>> getPassedModuleIds(String learningPathId) async {
    final rows =
        await (_db.select(_db.moduleTestProgressTable)
              ..where((t) => t.learningPathId.equals(learningPathId)))
            .get();
    return rows.map((r) => r.moduleId).toSet();
  }

  @override
  Future<bool> isModulePassed(String learningPathId, String moduleId) async {
    final row =
        await (_db.select(_db.moduleTestProgressTable)..where(
              (t) =>
                  t.learningPathId.equals(learningPathId) &
                  t.moduleId.equals(moduleId),
            ))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<int> getPassedModuleCount() async {
    final rows = await _db.select(_db.moduleTestProgressTable).get();
    return rows.length;
  }

  @override
  Future<void> markModulePassed({
    required String learningPathId,
    required String moduleId,
    required int scorePercent,
    required int questionCount,
  }) async {
    if (await isModulePassed(learningPathId, moduleId)) return;

    try {
      await _db
          .into(_db.moduleTestProgressTable)
          .insertOnConflictUpdate(
            ModuleTestProgressTableCompanion.insert(
              learningPathId: learningPathId,
              moduleId: moduleId,
              passedAt: DateTime.now(),
              scorePercent: scorePercent,
              questionCount: questionCount,
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException(
        'Failed to mark module $moduleId (path $learningPathId) passed: $e',
      );
    }
  }
}
