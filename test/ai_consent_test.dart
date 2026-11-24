import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/ai_teacher/domain/ai_provider.dart';
import 'package:teacher/features/ai_teacher/domain/api_key_repository.dart';
import 'package:teacher/features/ai_teacher/domain/consent_gated_ai_provider.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/ai_consent_providers.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/api_key_providers.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/teach_providers.dart';
import 'package:teacher/features/ai_teacher/presentation/widgets/ai_consent_dialog.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';
import 'package:teacher/features/settings/presentation/providers/settings_providers.dart';

class _Inner implements AIProvider {
  int calls = 0;

  @override
  Future<void> testConnection() async => calls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Keys implements ApiKeyRepository {
  @override
  Future<String?> getApiKey(AiProviderKind provider) async => 'k';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late List<AiProviderKind> asked;
  late Future<bool> Function() answer;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        apiKeyRepositoryProvider.overrideWithValue(_Keys()),
        aiConsentPromptProvider.overrideWithValue((p) {
          asked.add(p);
          return answer();
        }),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    asked = [];
    answer = () async => true;
  });
  tearDown(() => db.close());

  test('asks once per provider and remembers it after a restart', () async {
    final service = container().read(aiConsentServiceProvider);
    expect(await service.ensure(AiProviderKind.openai), isTrue);
    expect(await service.ensure(AiProviderKind.openai), isTrue);
    expect(await service.ensure(AiProviderKind.deepseek), isTrue);
    expect(asked, [AiProviderKind.openai, AiProviderKind.deepseek]);

    final restarted = container().read(aiConsentServiceProvider);
    expect(await restarted.ensure(AiProviderKind.openai), isTrue);
    expect(asked, hasLength(2));
  });

  test('a decline is not stored', () async {
    answer = () async => false;
    final service = container().read(aiConsentServiceProvider);
    expect(await service.ensure(AiProviderKind.gemini), isFalse);
    answer = () async => true;
    expect(await service.ensure(AiProviderKind.gemini), isTrue);
    expect(asked, hasLength(2));
  });

  test('simultaneous requests share one dialog', () async {
    final completer = Completer<bool>();
    answer = () => completer.future;
    final service = container().read(aiConsentServiceProvider);
    final results = Future.wait([
      service.ensure(AiProviderKind.gemini),
      service.ensure(AiProviderKind.gemini),
    ]);
    completer.complete(true);
    expect(await results, [true, true]);
    expect(asked, hasLength(1));
  });

  test('the gate blocks the request until allowed', () async {
    final inner = _Inner();
    var allowed = false;
    final gated = ConsentGatedAiProvider(
      inner: inner,
      ensureConsent: () async => allowed,
      providerName: 'Gemini',
    );
    await expectLater(
      gated.testConnection(),
      throwsA(isA<AiConsentDeclinedException>()),
    );
    expect(inner.calls, 0);
    allowed = true;
    await gated.testConnection();
    expect(inner.calls, 1);
  });

  test('every configured provider is gated', () async {
    final c = container();
    await c.read(settingsControllerProvider.future);
    for (final kind in AiProviderKind.values) {
      await c.read(settingsControllerProvider.notifier).setAiProviderKind(kind);
      await c.read(apiKeyControllerProvider(kind).future);
      expect(c.read(aiProviderProvider), isA<ConsentGatedAiProvider>());
    }
  });

  testWidgets('dialog names the recipient and returns the choice at 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showAiConsentDialog(
              context,
              AiProviderKind.anthropic,
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    for (final (label, expected) in [('Not now', false), ('Allow', true)]) {
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('Share data with Anthropic (Claude)?'), findsOneWidget);
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(result, expected);
    }
    expect(tester.takeException(), isNull);
  });
}
