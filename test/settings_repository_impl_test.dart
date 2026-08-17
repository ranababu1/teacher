import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/features/settings/data/settings_repository_impl.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';
import 'package:teacher/features/settings/domain/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsRepositoryImpl model settings', () {
    test('selectedModelByProvider is empty until a model is chosen', () async {
      final settings = await repository.getSettings();
      expect(settings.selectedModelByProvider, isEmpty);
    });

    test('setSelectedModel persists a model for exactly one provider', () async {
      await repository.setSelectedModel(AiProviderKind.openai, 'gpt-5.6-luna');

      final settings = await repository.getSettings();
      expect(settings.selectedModelByProvider[AiProviderKind.openai], 'gpt-5.6-luna');
      expect(settings.selectedModelByProvider.containsKey(AiProviderKind.gemini), isFalse);
    });

    test('customModelsByProvider round-trips a list, including a model id containing a comma', () async {
      await repository.setCustomModels(AiProviderKind.anthropic, [
        'claude-custom-1',
        'claude, custom, 2',
      ]);

      final settings = await repository.getSettings();
      expect(settings.customModelsByProvider[AiProviderKind.anthropic], [
        'claude-custom-1',
        'claude, custom, 2',
      ]);
    });

    test('different providers track selected models and custom lists independently', () async {
      await repository.setSelectedModel(AiProviderKind.gemini, 'gemini-custom');
      await repository.setSelectedModel(AiProviderKind.deepseek, 'deepseek-custom');
      await repository.setCustomModels(AiProviderKind.gemini, ['gemini-custom']);

      final settings = await repository.getSettings();
      expect(settings.selectedModelByProvider[AiProviderKind.gemini], 'gemini-custom');
      expect(settings.selectedModelByProvider[AiProviderKind.deepseek], 'deepseek-custom');
      expect(settings.customModelsByProvider[AiProviderKind.gemini], ['gemini-custom']);
      expect(settings.customModelsByProvider.containsKey(AiProviderKind.deepseek), isFalse);
    });

    test('an explicitly empty custom-models list round-trips as an empty list', () async {
      await repository.setCustomModels(AiProviderKind.openai, []);

      final settings = await repository.getSettings();
      expect(settings.customModelsByProvider[AiProviderKind.openai], isEmpty);
    });
  });
}
