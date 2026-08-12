import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/settings_models.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _keyThemeMode = 'theme_mode';
  static const _keyExplanationDepth = 'explanation_depth';
  static const _keyDailyTargetMinutes = 'daily_target_minutes';
  static const _keyDifficultyPreference = 'difficulty_preference';
  static const _keyWeeklyFlashcards = 'weekly_flashcards_enabled';
  static const _keyDebugMode = 'debug_mode';
  static const _keyAiRequestLogging = 'ai_request_logging';

  Future<String?> _read(String key) async {
    final row = await (_db.select(_db.settingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    try {
      await _db.into(_db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion.insert(key: key, value: value),
          );
    } on Exception catch (e) {
      throw LocalDatabaseException('Failed to write setting "$key": $e');
    }
  }

  @override
  Future<AppSettings> getSettings() async {
    final defaults = AppSettings.defaults;

    final themeModeKey = await _read(_keyThemeMode) ?? defaults.themeModeKey;
    final explanationDepthRaw = await _read(_keyExplanationDepth);
    final dailyTargetRaw = await _read(_keyDailyTargetMinutes);
    final difficultyRaw = await _read(_keyDifficultyPreference);
    final flashcardsRaw = await _read(_keyWeeklyFlashcards);
    final debugRaw = await _read(_keyDebugMode);
    final aiLoggingRaw = await _read(_keyAiRequestLogging);

    return AppSettings(
      themeModeKey: themeModeKey,
      explanationDepth: ExplanationDepth.values.firstWhere(
        (e) => e.name == explanationDepthRaw,
        orElse: () => defaults.explanationDepth,
      ),
      dailyTargetMinutes: int.tryParse(dailyTargetRaw ?? '') ?? defaults.dailyTargetMinutes,
      difficultyPreference: DifficultyPreference.values.firstWhere(
        (e) => e.name == difficultyRaw,
        orElse: () => defaults.difficultyPreference,
      ),
      weeklyFlashcardsEnabled: flashcardsRaw == null
          ? defaults.weeklyFlashcardsEnabled
          : flashcardsRaw == 'true',
      debugMode: debugRaw == null ? defaults.debugMode : debugRaw == 'true',
      aiRequestLogging:
          aiLoggingRaw == null ? defaults.aiRequestLogging : aiLoggingRaw == 'true',
    );
  }

  @override
  Future<void> setThemeModeKey(String themeModeKey) => _write(_keyThemeMode, themeModeKey);

  @override
  Future<void> setExplanationDepth(ExplanationDepth depth) =>
      _write(_keyExplanationDepth, depth.name);

  @override
  Future<void> setDailyTargetMinutes(int minutes) =>
      _write(_keyDailyTargetMinutes, minutes.toString());

  @override
  Future<void> setDifficultyPreference(DifficultyPreference preference) =>
      _write(_keyDifficultyPreference, preference.name);

  @override
  Future<void> setWeeklyFlashcardsEnabled(bool enabled) =>
      _write(_keyWeeklyFlashcards, enabled.toString());

  @override
  Future<void> setDebugMode(bool enabled) => _write(_keyDebugMode, enabled.toString());

  @override
  Future<void> setAiRequestLogging(bool enabled) =>
      _write(_keyAiRequestLogging, enabled.toString());
}
