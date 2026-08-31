import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/app_open_repository.dart';

/// Backed by the same generic [SettingsTable] key-value store used by
/// [LearnerProfileRepositoryImpl] — a plain JSON-encoded list of ISO
/// `yyyy-MM-dd` day strings under one key, no new Drift table needed.
class AppOpenRepositoryImpl implements AppOpenRepository {
  AppOpenRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _key = 'app_open_days';

  Future<Set<String>> _readDays() async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(_key))).getSingleOrNull();
    if (row == null) return {};
    return (jsonDecode(row.value) as List<dynamic>).cast<String>().toSet();
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  @override
  Future<int> getOpenDayCount() async => (await _readDays()).length;

  @override
  Future<bool> recordOpenToday() async {
    final days = await _readDays();
    final todayKey = _dayKey(DateTime.now());
    if (days.contains(todayKey)) return false;

    try {
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(
              key: _key,
              value: jsonEncode([...days, todayKey]),
            ),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to record app open day: $e');
    }
    return true;
  }
}
