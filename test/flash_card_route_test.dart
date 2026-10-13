import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:teacher/features/flashcards/domain/models/flash_card.dart';
import 'package:teacher/features/flashcards/presentation/screens/flash_card_screen.dart';

const _card = FlashCard(
  conceptId: 'c1',
  conceptTitle: 'Closures',
  front: 'What is a closure?',
  back: 'A function plus its captured scope.',
);

Widget _builder(BuildContext context, GoRouterState state) {
  final card = FlashCard.tryParse(state.extra);
  return card == null
      ? const FlashCardUnavailableScreen()
      : FlashCardScreen(card: card);
}

GoRouter _router({Object? extra}) => GoRouter(
  initialLocation: '/flash-card',
  initialExtra: extra,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const Text('Dashboard')),
    GoRoute(path: '/flash-card', builder: _builder),
  ],
);

void main() {
  group('FlashCard.tryParse', () {
    test('accepts a card, a JSON map, or a JSON string', () {
      expect(FlashCard.tryParse(_card), _card);
      expect(FlashCard.tryParse(_card.toJson()), _card);
      expect(FlashCard.tryParse(jsonEncode(_card.toJson())), _card);
    });

    test('returns null for missing or malformed data', () {
      expect(FlashCard.tryParse(null), isNull);
      expect(FlashCard.tryParse('not json'), isNull);
      expect(FlashCard.tryParse({'conceptId': 'c1'}), isNull);
      expect(FlashCard.tryParse(42), isNull);
    });
  });

  testWidgets('missing extra shows a friendly screen, not a crash', (
    tester,
  ) async {
    final router = _router();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('This flash card is no longer available'), findsOneWidget);

    // Opened as the first route, so closing must land on the dashboard.
    await tester.tap(find.text('Back to Teacher'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('a valid card still renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _router(extra: _card)),
    );
    await tester.pumpAndSettle();
    expect(find.text('What is a closure?'), findsOneWidget);
  });
}
