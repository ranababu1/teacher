import 'settings_models.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<void> setThemeModeKey(String themeModeKey);

  Future<void> setExplanationDepth(ExplanationDepth depth);

  Future<void> setDailyTargetMinutes(int minutes);

  Future<void> setDifficultyPreference(DifficultyPreference preference);

  Future<void> setWeeklyFlashcardsEnabled(bool enabled);

  Future<void> setFlashcardVolume(FlashcardVolume volume);

  Future<void> setFlashcardFrequencyMode(FlashcardFrequencyMode mode);

  Future<void> setFlashcardFixedTimes(List<String> times);

  Future<void> setDebugMode(bool enabled);

  Future<void> setAiRequestLogging(bool enabled);
}
