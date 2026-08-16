import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/secure_api_key_store.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';

void main() {
  group('SecureApiKeyStore.storageKeys', () {
    test('gemini keeps the exact pre-existing literal', () {
      // Existing installed users' keys already live under this literal —
      // changing it would silently lose their stored Gemini key.
      expect(SecureApiKeyStore.storageKeys[AiProviderKind.gemini], 'gemini_api_key');
    });

    test('every provider has a distinct storage key', () {
      final keys = SecureApiKeyStore.storageKeys.values.toSet();
      expect(keys.length, AiProviderKind.values.length);
    });

    test('every AiProviderKind has a mapped storage key', () {
      for (final provider in AiProviderKind.values) {
        expect(SecureApiKeyStore.storageKeys.containsKey(provider), isTrue);
      }
    });
  });
}
