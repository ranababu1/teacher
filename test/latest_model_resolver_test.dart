import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/latest_model_resolver.dart';

Map<String, dynamic> _list(List<Map<String, dynamic>> data) => {'data': data};

void main() {
  group('pickNewestClaudeSonnet', () {
    test(
      'picks the most recently released Sonnet, ignoring other families',
      () {
        final body = _list([
          {'id': 'claude-opus-5-5', 'created_at': '2026-10-01T00:00:00Z'},
          {'id': 'claude-sonnet-5-5', 'created_at': '2026-09-15T00:00:00Z'},
          {'id': 'claude-haiku-5-5', 'created_at': '2026-10-05T00:00:00Z'},
          {'id': 'claude-sonnet-5', 'created_at': '2026-03-01T00:00:00Z'},
        ]);
        expect(pickNewestClaudeSonnet(body), 'claude-sonnet-5-5');
      },
    );

    test('falls back to version order when release dates are unknown', () {
      final body = _list([
        {'id': 'claude-sonnet-5', 'created_at': '1970-01-01T00:00:00Z'},
        {'id': 'claude-sonnet-5-5', 'created_at': '1970-01-01T00:00:00Z'},
      ]);
      expect(pickNewestClaudeSonnet(body), 'claude-sonnet-5-5');
    });

    test('prefers the plain id over a dated snapshot', () {
      final body = _list([
        {
          'id': 'claude-sonnet-5-5-20260915',
          'created_at': '2026-09-15T00:00:00Z',
        },
        {'id': 'claude-sonnet-5-5', 'created_at': '2026-09-15T00:00:00Z'},
      ]);
      expect(pickNewestClaudeSonnet(body), 'claude-sonnet-5-5');
    });

    test('returns null when nothing matches or the body is malformed', () {
      expect(
        pickNewestClaudeSonnet(
          _list([
            {'id': 'claude-opus-5-5'},
          ]),
        ),
        isNull,
      );
      expect(pickNewestClaudeSonnet(null), isNull);
      expect(pickNewestClaudeSonnet({'data': 'nope'}), isNull);
      expect(pickNewestClaudeSonnet('<html>'), isNull);
    });
  });

  group('pickNewestGptTerra', () {
    test('picks the newest Terra and skips Pro, mini and batch variants', () {
      final body = _list([
        {'id': 'gpt-5.6-terra', 'created': 1767225600},
        {'id': 'gpt-6.1-terra', 'created': 1790000000},
        {'id': 'gpt-6.1-terra-pro', 'created': 1795000000},
        {'id': 'gpt-6.1-terra-batch', 'created': 1795000000},
        {'id': 'gpt-6.1-luna', 'created': 1796000000},
        {'id': 'gpt-6.1-terra-mini', 'created': 1796000000},
      ]);
      expect(pickNewestGptTerra(body), 'gpt-6.1-terra');
    });

    test('uses a terra-latest alias when OpenAI lists one', () {
      final body = _list([
        {'id': 'gpt-6.1-terra', 'created': 1790000000},
        {'id': 'gpt-terra-latest', 'created': 1700000000},
      ]);
      expect(pickNewestGptTerra(body), 'gpt-terra-latest');
    });

    test('does not match names that only contain the word', () {
      final body = _list([
        {'id': 'gpt-6.1-terraform-helper', 'created': 1790000000},
      ]);
      expect(pickNewestGptTerra(body), isNull);
    });
  });

  group('pickNewestDeepSeekFlash', () {
    test('prefers the unversioned deepseek-flash id', () {
      final body = _list([
        {'id': 'deepseek-v4-flash'},
        {'id': 'deepseek-flash'},
        {'id': 'deepseek-pro'},
      ]);
      expect(pickNewestDeepSeekFlash(body), 'deepseek-flash');
    });

    test('otherwise picks the highest Flash version', () {
      final body = _list([
        {'id': 'deepseek-v4-flash'},
        {'id': 'deepseek-v4.1-flash'},
        {'id': 'deepseek-v4-flash-preview'},
        {'id': 'deepseek-v4-pro'},
      ]);
      expect(pickNewestDeepSeekFlash(body), 'deepseek-v4.1-flash');
    });

    test('returns null when only non-Flash models are listed', () {
      final body = _list([
        {'id': 'deepseek-chat'},
        {'id': 'deepseek-reasoner'},
      ]);
      expect(pickNewestDeepSeekFlash(body), isNull);
    });
  });
}
