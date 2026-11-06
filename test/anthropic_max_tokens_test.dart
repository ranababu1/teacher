import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/anthropic_max_tokens.dart';

void main() {
  group('maxTokensForAnthropicModel', () {
    test('uses documented max for current Claude 5 models', () {
      expect(maxTokensForAnthropicModel('claude-sonnet-5'), 128000);
      expect(maxTokensForAnthropicModel('claude-sonnet-5-5'), 128000);
      expect(maxTokensForAnthropicModel('claude-opus-5-5'), 128000);
      expect(maxTokensForAnthropicModel('claude-haiku-5-5'), 128000);
    });

    test('uses documented max for Claude 4 families', () {
      expect(maxTokensForAnthropicModel('claude-sonnet-4-6'), 128000);
      expect(maxTokensForAnthropicModel('claude-sonnet-4-20250514'), 64000);
      expect(maxTokensForAnthropicModel('claude-opus-4-5'), 64000);
      expect(maxTokensForAnthropicModel('claude-opus-4-20250514'), 32000);
    });

    test('uses documented max for Claude 3 families', () {
      expect(maxTokensForAnthropicModel('claude-3-7-sonnet-latest'), 64000);
      expect(maxTokensForAnthropicModel('claude-3-5-sonnet-latest'), 8192);
      expect(maxTokensForAnthropicModel('claude-3-opus-20240229'), 4096);
    });

    test(
      'unknown models get the current-generation ceiling, not a low cap',
      () {
        expect(maxTokensForAnthropicModel('claude-test-model'), 128000);
        expect(maxTokensForAnthropicModel('claude-test-model'), isNot(30000));
        expect(maxTokensForAnthropicModel('claude-test-model'), isNot(16000));
      },
    );
  });
}
