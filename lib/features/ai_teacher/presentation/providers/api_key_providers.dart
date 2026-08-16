import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/domain/settings_models.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/secure_api_key_store.dart';
import '../../domain/api_key_repository.dart';

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  return const SecureApiKeyStore();
});

/// The learner's API key for a given [AiProviderKind], or null if none has
/// been entered yet.
class ApiKeyController extends FamilyAsyncNotifier<String?, AiProviderKind> {
  @override
  Future<String?> build(AiProviderKind provider) =>
      ref.watch(apiKeyRepositoryProvider).getApiKey(provider);

  Future<void> save(String apiKey) async {
    await ref.read(apiKeyRepositoryProvider).setApiKey(arg, apiKey);
    state = AsyncData(apiKey);
  }

  Future<void> clear() async {
    await ref.read(apiKeyRepositoryProvider).clearApiKey(arg);
    state = const AsyncData(null);
  }
}

final apiKeyControllerProvider =
    AsyncNotifierProvider.family<ApiKeyController, String?, AiProviderKind>(
      ApiKeyController.new,
    );

/// Whether the currently selected AI provider has a usable API key
/// configured.
final isAiConfiguredProvider = Provider<bool>((ref) {
  final selected =
      ref.watch(settingsControllerProvider).valueOrNull?.aiProviderKind ??
      AiProviderKind.gemini;
  final key = ref.watch(apiKeyControllerProvider(selected)).valueOrNull;
  return key != null && key.isNotEmpty;
});
