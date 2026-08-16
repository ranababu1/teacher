import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../settings/domain/settings_models.dart';
import '../domain/api_key_repository.dart';

/// Backed by the platform's hardware-rooted secure storage — Android
/// Keystore (AES-GCM with RSA-OAEP key wrapping) on Android, Keychain on
/// iOS/macOS. The key is encrypted at rest and is not extractable by
/// unpacking the APK or reading app files off a non-rooted device.
///
/// This is not a claim of absolute immunity from reverse engineering —
/// nothing running on a device the attacker fully controls can be. It
/// defeats the practical attacks that matter here: static extraction from
/// the APK, and casual file copying. A bundled `.env`-style secret would
/// defend against neither, since it ships inside the APK's assets.
class SecureApiKeyStore implements ApiKeyRepository {
  const SecureApiKeyStore();

  static const _storage = FlutterSecureStorage();

  // gemini keeps this exact pre-existing literal so keys already stored by
  // installed users keep working with no migration step.
  @visibleForTesting
  static const storageKeys = {
    AiProviderKind.gemini: 'gemini_api_key',
    AiProviderKind.openai: 'openai_api_key',
    AiProviderKind.anthropic: 'anthropic_api_key',
    AiProviderKind.deepseek: 'deepseek_api_key',
  };

  @override
  Future<String?> getApiKey(AiProviderKind provider) =>
      _storage.read(key: storageKeys[provider]!);

  @override
  Future<void> setApiKey(AiProviderKind provider, String apiKey) =>
      _storage.write(key: storageKeys[provider]!, value: apiKey);

  @override
  Future<void> clearApiKey(AiProviderKind provider) =>
      _storage.delete(key: storageKeys[provider]!);
}
