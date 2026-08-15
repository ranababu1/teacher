import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/misconception_repository.dart';
import '../domain/models/detected_misconception.dart';

class MisconceptionRepositoryImpl implements MisconceptionRepository {
  MisconceptionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<DetectedMisconception>> getUnresolvedForConcept(
    String conceptId,
  ) async {
    final rows =
        await (_db.select(_db.misconceptionsTable)
              ..where(
                (t) => t.conceptId.equals(conceptId) & t.resolvedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<DetectedMisconception> recordMisconception({
    required String conceptId,
    required String description,
    double confidence = 1.0,
  }) async {
    try {
      final detectedAt = DateTime.now();
      final id = await _db
          .into(_db.misconceptionsTable)
          .insert(
            MisconceptionsTableCompanion.insert(
              conceptId: conceptId,
              description: description,
              detectedAt: detectedAt,
              confidence: Value(confidence),
            ),
          );
      return DetectedMisconception(
        id: id,
        conceptId: conceptId,
        description: description,
        detectedAt: detectedAt,
        confidence: confidence,
      );
    } on Exception catch (e) {
      throw LocalDatabaseException(
        'Failed to record misconception for $conceptId: $e',
      );
    }
  }

  @override
  Future<void> resolveMisconception(int id) async {
    try {
      await (_db.update(
        _db.misconceptionsTable,
      )..where((t) => t.id.equals(id))).write(
        MisconceptionsTableCompanion(resolvedAt: Value(DateTime.now())),
      );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to resolve misconception $id: $e');
    }
  }

  DetectedMisconception _toDomain(MisconceptionsTableData row) {
    return DetectedMisconception(
      id: row.id,
      conceptId: row.conceptId,
      description: row.description,
      detectedAt: row.detectedAt,
      confidence: row.confidence,
      resolvedAt: row.resolvedAt,
    );
  }
}
