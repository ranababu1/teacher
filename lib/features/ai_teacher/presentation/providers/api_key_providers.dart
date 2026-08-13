import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/secure_api_key_store.dart';
import '../../domain/api_key_repository.dart';

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  return const SecureApiKeyStore();
});

/// The learner's Gemini API key, or null if none has been entered yet.
class GeminiApiKeyController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() =>
      ref.watch(apiKeyRepositoryProvider).getGeminiApiKey();

  Future<void> save(String apiKey) async {
    await ref.read(apiKeyRepositoryProvider).setGeminiApiKey(apiKey);
    state = AsyncData(apiKey);
  }

  Future<void> clear() async {
    await ref.read(apiKeyRepositoryProvider).clearGeminiApiKey();
    state = const AsyncData(null);
  }
}

final geminiApiKeyControllerProvider =
    AsyncNotifierProvider<GeminiApiKeyController, String?>(
      GeminiApiKeyController.new,
    );

/// Whether the AI teacher currently has a usable API key configured.
final isAiConfiguredProvider = Provider<bool>((ref) {
  final key = ref.watch(geminiApiKeyControllerProvider).valueOrNull;
  return key != null && key.isNotEmpty;
});
