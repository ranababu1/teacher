import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/gemini_error_classifier.dart';

void main() {
  group('classifyGeminiError', () {
    test('an "API key not valid" message is recognized regardless of status', () {
      final message = classifyGeminiError(
        statusCode: 400,
        responseBody: {
          'error': {
            'code': 400,
            'message': 'API key not valid. Please pass a valid API key.',
            'status': 'INVALID_ARGUMENT',
          },
        },
      );
      expect(message, contains('API key'));
    });

    test('UNAUTHENTICATED status maps to a bad-key message', () {
      final message = classifyGeminiError(
        statusCode: 401,
        responseBody: {
          'error': {'status': 'UNAUTHENTICATED', 'message': 'no credentials'},
        },
      );
      expect(message, contains('API key'));
    });

    test('PERMISSION_DENIED status maps to a permission message', () {
      final message = classifyGeminiError(
        statusCode: 403,
        responseBody: {
          'error': {'status': 'PERMISSION_DENIED', 'message': 'denied'},
        },
      );
      expect(message, contains("doesn't have permission"));
    });

    test('RESOURCE_EXHAUSTED status maps to a rate-limit message', () {
      final message = classifyGeminiError(
        statusCode: 429,
        responseBody: {
          'error': {'status': 'RESOURCE_EXHAUSTED', 'message': 'quota'},
        },
      );
      expect(message, contains('usage limit'));
    });

    test('UNAVAILABLE status maps to a server-busy message', () {
      final message = classifyGeminiError(
        statusCode: 503,
        responseBody: {
          'error': {
            'status': 'UNAVAILABLE',
            'message': 'model overloaded, please retry',
          },
        },
      );
      expect(message, contains('temporarily busy'));
    });

    test('falls back to the HTTP status code when the body has no canonical status', () {
      final message = classifyGeminiError(statusCode: 429, responseBody: null);
      expect(message, contains('usage limit'));
    });

    test('falls back to a generic message for an unrecognized status code', () {
      final message = classifyGeminiError(statusCode: 418, responseBody: null);
      expect(message, "The AI teacher isn't available right now. Try again shortly.");
    });

    test('does not throw on a malformed (non-map) response body', () {
      expect(
        () => classifyGeminiError(statusCode: 500, responseBody: 'plain text error'),
        returnsNormally,
      );
    });
  });
}
