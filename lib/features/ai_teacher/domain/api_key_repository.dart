import '../../settings/domain/settings_models.dart';

/// Stores the learner's own AI provider API key.
///
/// Each user supplies their own key at runtime — it is never bundled with
/// the app, never committed to source control, and never sent anywhere
/// except directly to the AI provider. See instructions.md section 27.
abstract class ApiKeyRepository {
  Future<String?> getApiKey(AiProviderKind provider);

  Future<void> setApiKey(AiProviderKind provider, String apiKey);

  Future<void> clearApiKey(AiProviderKind provider);
}
