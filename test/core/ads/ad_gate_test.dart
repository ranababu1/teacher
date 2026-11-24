import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/ads/ad_gate.dart';

void main() {
  late DateTime now;
  late bool aiBusy;
  late AdGate gate;

  void advance(Duration d) => now = now.add(d);

  setUp(() {
    now = DateTime(2026, 11, 24, 9);
    aiBusy = false;
    gate = AdGate(clock: () => now, isAiBusy: () => aiBusy);
  });

  group('5 minute grace period', () {
    test('no ad before 5 minutes of use', () {
      expect(gate.canShow, isFalse);
      advance(const Duration(minutes: 4, seconds: 59));
      expect(gate.canShow, isFalse);
    });

    test('ad allowed at 5 minutes', () {
      advance(const Duration(minutes: 5));
      expect(gate.canShow, isTrue);
    });

    test('background time does not count', () {
      advance(const Duration(minutes: 3));
      gate.onBackground();
      advance(const Duration(hours: 1));
      expect(gate.usage, const Duration(minutes: 3));
      expect(gate.canShow, isFalse);
      gate.onForeground();
      advance(const Duration(minutes: 1, seconds: 59));
      expect(gate.canShow, isFalse);
      advance(const Duration(seconds: 1));
      expect(gate.canShow, isTrue);
    });
  });

  group('3 minute interval', () {
    setUp(() => advance(const Duration(minutes: 5)));

    test('no second ad within 3 minutes of the last one', () {
      expect(gate.canShow, isTrue);
      gate.recordShown();
      expect(gate.canShow, isFalse);
      advance(const Duration(minutes: 2, seconds: 59));
      expect(gate.canShow, isFalse);
    });

    test('next ad allowed 3 minutes after the last one', () {
      gate.recordShown();
      advance(const Duration(minutes: 3));
      expect(gate.canShow, isTrue);
    });

    test('interval counts foreground time only', () {
      gate.recordShown();
      advance(const Duration(minutes: 1));
      gate.onBackground();
      advance(const Duration(minutes: 30));
      gate.onForeground();
      expect(gate.canShow, isFalse);
      advance(const Duration(minutes: 2));
      expect(gate.canShow, isTrue);
    });
  });

  group('blocked screens and AI requests', () {
    setUp(() => advance(const Duration(minutes: 10)));

    test('blocked while a test screen is open', () {
      final testScreen = Object();
      gate.block(testScreen);
      expect(gate.canShow, isFalse);
      gate.unblock(testScreen);
      expect(gate.canShow, isTrue);
    });

    test('stays blocked until every blocking screen is gone', () {
      final skillCheck = Object();
      final review = Object();
      gate.block(skillCheck);
      gate.block(review);
      gate.unblock(skillCheck);
      expect(gate.canShow, isFalse);
      gate.unblock(review);
      expect(gate.canShow, isTrue);
    });

    test('blocked during an AI request', () {
      aiBusy = true;
      expect(gate.canShow, isFalse);
      aiBusy = false;
      expect(gate.canShow, isTrue);
    });

    test('blocked while the app is in the background', () {
      gate.onBackground();
      expect(gate.canShow, isFalse);
    });

    test('blocking does not reset the timers', () {
      final interview = Object();
      gate.block(interview);
      advance(const Duration(minutes: 5));
      gate.unblock(interview);
      expect(gate.usage, const Duration(minutes: 15));
      expect(gate.canShow, isTrue);
    });
  });
}
