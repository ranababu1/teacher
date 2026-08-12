import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/student_progress.dart';
import '../domain/student_progress_repository.dart';

class StudentProgressRepositoryImpl implements StudentProgressRepository {
  StudentProgressRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<StudentProgress?> getProgress(String conceptId) async {
    final row = await (_db.select(
      _db.studentProgressTable,
    )..where((t) => t.conceptId.equals(conceptId))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<StudentProgress>> getAllProgress() async {
    final rows = await _db.select(_db.studentProgressTable).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> markStarted({
    required String conceptId,
    required String learningPathId,
    required String moduleId,
  }) async {
    try {
      final now = DateTime.now();
      final existing = await getProgress(conceptId);

      await _db
          .into(_db.studentProgressTable)
          .insertOnConflictUpdate(
            StudentProgressTableCompanion.insert(
              conceptId: conceptId,
              learningPathId: learningPathId,
              moduleId: moduleId,
              startedAt: Value(existing?.startedAt ?? now),
              lastAccessedAt: Value(now),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to mark $conceptId started: $e');
    }
  }

  @override
  Future<void> markCompleted(String conceptId) async {
    final existing = await getProgress(conceptId);
    if (existing == null || existing.isCompleted) return;

    try {
      await (_db.update(
        _db.studentProgressTable,
      )..where((t) => t.conceptId.equals(conceptId))).write(
        StudentProgressTableCompanion(completedAt: Value(DateTime.now())),
      );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to mark $conceptId completed: $e');
    }
  }

  StudentProgress _toDomain(StudentProgressTableData row) {
    return StudentProgress(
      conceptId: row.conceptId,
      learningPathId: row.learningPathId,
      moduleId: row.moduleId,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      lastAccessedAt: row.lastAccessedAt,
    );
  }
}
