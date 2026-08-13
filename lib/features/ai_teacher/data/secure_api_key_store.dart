import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  static const _geminiKeyStorageKey = 'gemini_api_key';

  @override
  Future<String?> getGeminiApiKey() => _storage.read(key: _geminiKeyStorageKey);

  @override
  Future<void> setGeminiApiKey(String apiKey) =>
      _storage.write(key: _geminiKeyStorageKey, value: apiKey);

  @override
  Future<void> clearGeminiApiKey() =>
      _storage.delete(key: _geminiKeyStorageKey);
}
