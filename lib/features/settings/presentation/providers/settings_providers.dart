import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/settings_repository_impl.dart';
import '../../domain/settings_models.dart';
import '../../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> setThemeMode(String themeModeKey) async {
    await ref.read(settingsRepositoryProvider).setThemeModeKey(themeModeKey);
    _update((s) => s.copyWith(themeModeKey: themeModeKey));
  }

  Future<void> setExplanationDepth(ExplanationDepth depth) async {
    await ref.read(settingsRepositoryProvider).setExplanationDepth(depth);
    _update((s) => s.copyWith(explanationDepth: depth));
  }

  Future<void> setDailyTargetMinutes(int minutes) async {
    await ref.read(settingsRepositoryProvider).setDailyTargetMinutes(minutes);
    _update((s) => s.copyWith(dailyTargetMinutes: minutes));
  }

  Future<void> setDifficultyPreference(DifficultyPreference preference) async {
    await ref
        .read(settingsRepositoryProvider)
        .setDifficultyPreference(preference);
    _update((s) => s.copyWith(difficultyPreference: preference));
  }

  Future<void> setWeeklyFlashcardsEnabled(bool enabled) async {
    await ref
        .read(settingsRepositoryProvider)
        .setWeeklyFlashcardsEnabled(enabled);
    _update((s) => s.copyWith(weeklyFlashcardsEnabled: enabled));
  }

  Future<void> setFlashcardVolume(FlashcardVolume volume) async {
    await ref.read(settingsRepositoryProvider).setFlashcardVolume(volume);
    _update((s) => s.copyWith(flashcardVolume: volume));
  }

  Future<void> setFlashcardFrequencyMode(FlashcardFrequencyMode mode) async {
    await ref
        .read(settingsRepositoryProvider)
        .setFlashcardFrequencyMode(mode);
    _update((s) => s.copyWith(flashcardFrequencyMode: mode));
  }

  Future<void> setFlashcardFixedTimes(List<String> times) async {
    await ref.read(settingsRepositoryProvider).setFlashcardFixedTimes(times);
    _update((s) => s.copyWith(flashcardFixedTimes: times));
  }

  Future<void> setDebugMode(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setDebugMode(enabled);
    _update((s) => s.copyWith(debugMode: enabled));
  }

  Future<void> setAiRequestLogging(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setAiRequestLogging(enabled);
    _update((s) => s.copyWith(aiRequestLogging: enabled));
  }

  void _update(AppSettings Function(AppSettings) transform) {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(transform(current));
    }
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

/// Derived theme mode for [MaterialApp.themeMode], defaulting to system
/// while settings are still loading.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  switch (settings?.themeModeKey) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});
