import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/models/item_type.dart';
import '../domain/attempts_repository.dart';
import '../domain/models/attempt.dart';
import '../domain/models/attempt_outcome.dart';

class AttemptsRepositoryImpl implements AttemptsRepository {
  AttemptsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<Attempt> saveAttempt({
    required String conceptId,
    required String itemId,
    required ItemKind itemKind,
    required ItemType itemType,
    required AttemptOutcome outcome,
  }) async {
    try {
      final id = await _db
          .into(_db.attemptsTable)
          .insert(
            AttemptsTableCompanion.insert(
              conceptId: conceptId,
              itemId: itemId,
              itemKind: itemKind.name,
              itemType: itemType.name,
              isCorrect: Value(outcome.isCorrect),
              selfRating: Value(outcome.selfRating?.score),
              hintsUsed: Value(outcome.hintsUsed),
              userResponse: Value(outcome.userResponse),
              createdAt: DateTime.now(),
            ),
          );

      final row = await (_db.select(
        _db.attemptsTable,
      )..where((t) => t.id.equals(id))).getSingle();
      return _toDomain(row);
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save attempt: $e');
    }
  }

  @override
  Future<List<Attempt>> getAttemptsForConcept(String conceptId) async {
    final rows =
        await (_db.select(_db.attemptsTable)
              ..where((t) => t.conceptId.equals(conceptId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<Attempt>> getRecentAttempts({int limit = 20}) async {
    final rows =
        await (_db.select(_db.attemptsTable)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(limit))
            .get();
    return rows.map(_toDomain).toList();
  }

  Attempt _toDomain(AttemptsTableData row) {
    return Attempt(
      id: row.id,
      conceptId: row.conceptId,
      itemId: row.itemId,
      itemKind: ItemKind.values.firstWhere((k) => k.name == row.itemKind),
      itemType: ItemType.fromJson(row.itemType),
      isCorrect: row.isCorrect,
      selfRating: row.selfRating,
      hintsUsed: row.hintsUsed,
      userResponse: row.userResponse,
      createdAt: row.createdAt,
    );
  }
}
