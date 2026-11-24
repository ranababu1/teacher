import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_config_provider.dart';
import '../../../settings/domain/settings_models.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/latest_model_resolver.dart';
import 'api_key_providers.dart';

final latestModelResolverProvider = Provider<LatestModelResolver>(
  (ref) => LatestModelResolver(),
);

/// The newest model of [AiProviderKind]'s family (Claude Sonnet, GPT Terra,
/// DeepSeek Flash), looked up once per app launch, or null when it can't
/// be resolved; callers then use [AppConfig]'s built-in default.
///
/// Only runs once the learner has saved a key for that provider and agreed
/// to send it data (the AI consent dialog), and re-runs if the key changes.
/// The request carries the API key and nothing about the learner.
final latestModelProvider = FutureProvider.family<String?, AiProviderKind>((
  ref,
  provider,
) async {
  if (provider == AiProviderKind.gemini) return null;
  final apiKey = ref.watch(apiKeyControllerProvider(provider)).valueOrNull;
  if (apiKey == null || apiKey.isEmpty) return null;
  final consented = ref.watch(
    settingsControllerProvider.select(
      (s) => s.valueOrNull?.aiConsentProviders.contains(provider) ?? false,
    ),
  );
  if (!consented) return null;
  final config = ref.watch(appConfigProvider);
  return ref
      .read(latestModelResolverProvider)
      .resolve(
        provider: provider,
        apiKey: apiKey,
        baseUrl: baseUrlFor(provider, config),
      );
});

String baseUrlFor(AiProviderKind provider, AppConfig config) =>
    switch (provider) {
      AiProviderKind.gemini => config.geminiApiBaseUrl,
      AiProviderKind.openai => config.openAiApiBaseUrl,
      AiProviderKind.anthropic => config.anthropicApiBaseUrl,
      AiProviderKind.deepseek => config.deepSeekApiBaseUrl,
    };

/// The built-in default model for [provider], used when the learner hasn't
/// pinned a model and the latest one can't be resolved.
String defaultModelFor(AiProviderKind provider, AppConfig config) =>
    switch (provider) {
      AiProviderKind.gemini => config.geminiModel,
      AiProviderKind.openai => config.openAiModel,
      AiProviderKind.anthropic => config.anthropicModel,
      AiProviderKind.deepseek => config.deepSeekModel,
    };

/// The model "Latest" currently means for [provider]: the resolved newest
/// model when known, otherwise the built-in default.
final automaticModelProvider = Provider.family<String, AiProviderKind>((
  ref,
  provider,
) {
  final resolved = ref.watch(latestModelProvider(provider)).valueOrNull;
  if (resolved != null && resolved.isNotEmpty) return resolved;
  return defaultModelFor(provider, ref.watch(appConfigProvider));
});
