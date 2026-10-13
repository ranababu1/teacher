import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/services/crash_reporting_service.dart';

void main() {
  setUp(CrashReportingService.resetForTesting);

  test(
    'a failing Firebase init does not throw and leaves reporting off',
    () async {
      await CrashReportingService.initialize(
        isSupportedPlatform: true,
        initializeFirebase: () async => throw Exception('no google-services'),
      );
      expect(CrashReportingService.isAvailable, isFalse);
      // Settings toggle must stay a safe no-op.
      await CrashReportingService.setCollectionEnabled(false);
    },
  );

  test('unsupported platforms skip Firebase entirely', () async {
    var called = false;
    await CrashReportingService.initialize(
      isSupportedPlatform: false,
      initializeFirebase: () async => called = true,
    );
    expect(called, isFalse);
    expect(CrashReportingService.isAvailable, isFalse);
  });
}
