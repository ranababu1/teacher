import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ads/domain/ad_gate.dart';

void main() {
  late DateTime now;
  AdGate gate() => AdGate(
    warmUp: const Duration(minutes: 5),
    minGap: const Duration(minutes: 3),
    now: () => now,
  );

  setUp(() => now = DateTime(2026, 1, 1, 9));

  void advance(Duration d) => now = now.add(d);

  test('no ads in the first 5 minutes of usage', () {
    final g = gate();
    advance(const Duration(minutes: 4, seconds: 59));
    expect(g.canShow, isFalse);
    advance(const Duration(seconds: 1));
    expect(g.canShow, isTrue);
  });

  test('then at most one ad every 3 minutes', () {
    final g = gate();
    advance(const Duration(minutes: 6));
    expect(g.canShow, isTrue);
    g.markShown();
    advance(const Duration(minutes: 2, seconds: 59));
    expect(g.canShow, isFalse);
    advance(const Duration(seconds: 1));
    expect(g.canShow, isTrue);
  });

  test('background time does not count as usage', () {
    final g = gate();
    advance(const Duration(minutes: 2));
    g.onBackground();
    advance(const Duration(hours: 1));
    expect(g.canShow, isFalse);
    g.onForeground();
    advance(const Duration(minutes: 3));
    expect(g.usage, const Duration(minutes: 5));
    expect(g.canShow, isTrue);
  });

  test('never inside a no-ads zone such as a test', () {
    final g = gate();
    advance(const Duration(minutes: 10));
    g.enterNoAdsZone();
    expect(g.canShow, isFalse);
    g.exitNoAdsZone();
    expect(g.canShow, isTrue);
  });

  test('never while an AI request runs', () {
    final g = gate();
    advance(const Duration(minutes: 10));
    g.aiRequestStarted();
    g.aiRequestStarted();
    g.aiRequestFinished();
    expect(g.canShow, isFalse);
    g.aiRequestFinished();
    expect(g.canShow, isTrue);
  });
}
