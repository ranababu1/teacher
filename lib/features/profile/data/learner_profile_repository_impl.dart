import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/learner_profile_repository.dart';
import '../domain/models/learner_profile.dart';

class LearnerProfileRepositoryImpl implements LearnerProfileRepository {
  LearnerProfileRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _keyName = 'learner_name';
  static const _keyCareerGoal = 'learner_career_goal';
  static const _keyHasOnboarded = 'learner_has_onboarded';

  Future<String?> _read(String key) async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    try {
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(key: key, value: value),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to write setting "$key": $e');
    }
  }

  Future<void> _delete(String key) async {
    await (_db.delete(
      _db.settingsTable,
    )..where((t) => t.key.equals(key))).go();
  }

  @override
  Future<LearnerProfile> getProfile() async {
    final name = await _read(_keyName) ?? LearnerProfile.empty.name;
    final careerGoal = await _read(_keyCareerGoal);
    final hasOnboardedRaw = await _read(_keyHasOnboarded);

    return LearnerProfile(
      name: name,
      careerGoal: careerGoal,
      hasCompletedOnboarding: hasOnboardedRaw == 'true',
    );
  }

  @override
  Future<void> completeOnboarding({
    required String name,
    String? careerGoal,
  }) async {
    await _write(_keyName, name);
    if (careerGoal == null || careerGoal.isEmpty) {
      await _delete(_keyCareerGoal);
    } else {
      await _write(_keyCareerGoal, careerGoal);
    }
    await _write(_keyHasOnboarded, 'true');
  }

  @override
  Future<void> setName(String name) => _write(_keyName, name);

  @override
  Future<void> setCareerGoal(String? careerGoal) {
    if (careerGoal == null || careerGoal.isEmpty) {
      return _delete(_keyCareerGoal);
    }
    return _write(_keyCareerGoal, careerGoal);
  }
}
