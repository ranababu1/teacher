import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/concept_mastery_repository.dart';
import '../domain/models/concept_mastery.dart';
import '../domain/models/mastery_status.dart';

class ConceptMasteryRepositoryImpl implements ConceptMasteryRepository {
  ConceptMasteryRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ConceptMastery> getMastery(String conceptId) async {
    final row = await (_db.select(
      _db.conceptMasteryTable,
    )..where((t) => t.conceptId.equals(conceptId))).getSingleOrNull();
    return row == null ? ConceptMastery.empty(conceptId) : _toDomain(row);
  }

  @override
  Future<List<ConceptMastery>> getAllMastery() async {
    final rows = await _db.select(_db.conceptMasteryTable).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> saveMastery(ConceptMastery mastery) async {
    try {
      await _db
          .into(_db.conceptMasteryTable)
          .insertOnConflictUpdate(
            ConceptMasteryTableCompanion.insert(
              conceptId: mastery.conceptId,
              recallScore: Value(mastery.recallScore),
              understandingScore: Value(mastery.understandingScore),
              applicationScore: Value(mastery.applicationScore),
              explanationScore: Value(mastery.explanationScore),
              codingScore: Value(mastery.codingScore),
              debuggingScore: Value(mastery.debuggingScore),
              overallMastery: Value(mastery.overallMastery),
              attemptCount: Value(mastery.attemptCount),
              successCount: Value(mastery.successCount),
              failureCount: Value(mastery.failureCount),
              confidence: Value(mastery.confidence),
              lastReviewedAt: Value(mastery.lastReviewedAt),
              nextReviewAt: Value(mastery.nextReviewAt),
              status: Value(mastery.status.name),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException(
        'Failed to save mastery for ${mastery.conceptId}: $e',
      );
    }
  }

  ConceptMastery _toDomain(ConceptMasteryTableData row) {
    return ConceptMastery(
      conceptId: row.conceptId,
      recallScore: row.recallScore,
      understandingScore: row.understandingScore,
      applicationScore: row.applicationScore,
      explanationScore: row.explanationScore,
      codingScore: row.codingScore,
      debuggingScore: row.debuggingScore,
      overallMastery: row.overallMastery,
      attemptCount: row.attemptCount,
      successCount: row.successCount,
      failureCount: row.failureCount,
      confidence: row.confidence,
      lastReviewedAt: row.lastReviewedAt,
      nextReviewAt: row.nextReviewAt,
      status: MasteryStatus.fromJson(row.status),
    );
  }
}
