import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/models/review_schedule.dart';
import '../domain/review_schedule_repository.dart';

class ReviewScheduleRepositoryImpl implements ReviewScheduleRepository {
  ReviewScheduleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ReviewSchedule> getSchedule(String conceptId) async {
    final row = await (_db.select(_db.reviewScheduleTable)
          ..where((t) => t.conceptId.equals(conceptId)))
        .getSingleOrNull();
    return row == null ? ReviewSchedule.initial(conceptId) : _toDomain(row);
  }

  @override
  Future<List<ReviewSchedule>> getDueSchedules() async {
    final now = DateTime.now();
    final rows = await (_db.select(_db.reviewScheduleTable)
          ..where((t) => t.dueAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> saveSchedule(ReviewSchedule schedule) async {
    try {
      await _db.into(_db.reviewScheduleTable).insertOnConflictUpdate(
            ReviewScheduleTableCompanion.insert(
              conceptId: schedule.conceptId,
              dueAt: schedule.dueAt,
              intervalDays: Value(schedule.intervalDays),
              lastReviewedAt: Value(schedule.lastReviewedAt),
              reviewCount: Value(schedule.reviewCount),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to save review schedule for ${schedule.conceptId}: $e');
    }
  }

  ReviewSchedule _toDomain(ReviewScheduleTableData row) {
    return ReviewSchedule(
      conceptId: row.conceptId,
      dueAt: row.dueAt,
      intervalDays: row.intervalDays,
      lastReviewedAt: row.lastReviewedAt,
      reviewCount: row.reviewCount,
    );
  }
}
