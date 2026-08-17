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

  Future<void> setAiProviderKind(AiProviderKind kind) async {
    await ref.read(settingsRepositoryProvider).setAiProviderKind(kind);
    _update((s) => s.copyWith(aiProviderKind: kind));
  }

  /// Selects [model] as the active model for [provider]. Pass an empty
  /// string to clear the selection and fall back to that provider's
  /// built-in default (see [SettingsRepositoryImpl.getSettings], which
  /// only populates a provider's map entry for a non-empty stored value).
  Future<void> setSelectedModel(AiProviderKind provider, String model) async {
    await ref.read(settingsRepositoryProvider).setSelectedModel(provider, model);
    _update((s) {
      final updated = Map<AiProviderKind, String>.from(s.selectedModelByProvider);
      if (model.isEmpty) {
        updated.remove(provider);
      } else {
        updated[provider] = model;
      }
      return s.copyWith(selectedModelByProvider: updated);
    });
  }

  /// Adds [model] to [provider]'s custom model list. No-op if blank or
  /// already present (case-sensitive, matching how provider APIs treat
  /// model ids).
  Future<void> addCustomModel(AiProviderKind provider, String model) async {
    final trimmed = model.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.customModelsByProvider[provider] ?? const <String>[];
    if (existing.contains(trimmed)) return;

    final updatedList = [...existing, trimmed];
    await ref.read(settingsRepositoryProvider).setCustomModels(provider, updatedList);
    _update((s) {
      final updated = Map<AiProviderKind, List<String>>.from(s.customModelsByProvider);
      updated[provider] = updatedList;
      return s.copyWith(customModelsByProvider: updated);
    });
  }

  /// Renames a custom model entry. Only ever operates on entries already
  /// present in [provider]'s custom list — since the app's built-in
  /// baseline models are never stored there, this can't touch a baseline
  /// model even if [oldModel] happens to match one. If [oldModel] was the
  /// selected model, the selection follows the rename.
  Future<void> renameCustomModel(
    AiProviderKind provider,
    String oldModel,
    String newModel,
  ) async {
    final trimmed = newModel.trim();
    if (trimmed.isEmpty || trimmed == oldModel) return;
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.customModelsByProvider[provider] ?? const <String>[];
    if (!existing.contains(oldModel) || existing.contains(trimmed)) return;

    final updatedList = [
      for (final m in existing) m == oldModel ? trimmed : m,
    ];
    await ref.read(settingsRepositoryProvider).setCustomModels(provider, updatedList);

    final wasSelected = current.selectedModelByProvider[provider] == oldModel;
    if (wasSelected) {
      await ref.read(settingsRepositoryProvider).setSelectedModel(provider, trimmed);
    }

    _update((s) {
      final updatedModels = Map<AiProviderKind, List<String>>.from(s.customModelsByProvider);
      updatedModels[provider] = updatedList;
      final updatedSelected = Map<AiProviderKind, String>.from(s.selectedModelByProvider);
      if (wasSelected) updatedSelected[provider] = trimmed;
      return s.copyWith(
        customModelsByProvider: updatedModels,
        selectedModelByProvider: updatedSelected,
      );
    });
  }

  /// Removes a custom model entry. If it was the selected model, the
  /// selection is cleared so the provider's baseline default takes over.
  Future<void> removeCustomModel(AiProviderKind provider, String model) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.customModelsByProvider[provider] ?? const <String>[];
    if (!existing.contains(model)) return;

    final updatedList = existing.where((m) => m != model).toList();
    await ref.read(settingsRepositoryProvider).setCustomModels(provider, updatedList);

    final wasSelected = current.selectedModelByProvider[provider] == model;
    if (wasSelected) {
      await ref.read(settingsRepositoryProvider).setSelectedModel(provider, '');
    }

    _update((s) {
      final updatedModels = Map<AiProviderKind, List<String>>.from(s.customModelsByProvider);
      updatedModels[provider] = updatedList;
      final updatedSelected = Map<AiProviderKind, String>.from(s.selectedModelByProvider);
      if (wasSelected) updatedSelected.remove(provider);
      return s.copyWith(
        customModelsByProvider: updatedModels,
        selectedModelByProvider: updatedSelected,
      );
    });
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
