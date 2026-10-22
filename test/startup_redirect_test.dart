import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/app/startup_redirect.dart';
import 'package:teacher/core/constants/routes.dart';
import 'package:teacher/features/profile/domain/models/learner_profile.dart';

const _done = LearnerProfile(
  name: 'Imran',
  careerGoal: null,
  hasCompletedOnboarding: true,
);

String? _redirect(AsyncValue<LearnerProfile> profile, String location) =>
    startupRedirect(profile: profile, uri: Uri.parse(location));

void main() {
  group('while the profile is loading', () {
    const loading = AsyncLoading<LearnerProfile>();

    test('parks the first location on the blank launch page', () {
      final target = _redirect(loading, Routes.dashboard);
      expect(Uri.parse(target!).path, Routes.launch);
      expect(Uri.parse(target).queryParameters['from'], Routes.dashboard);
    });

    test('stays on the launch page', () {
      expect(_redirect(loading, '${Routes.launch}?from=%2F'), isNull);
    });
  });

  group('fresh install (onboarding not done)', () {
    const fresh = AsyncData(LearnerProfile.empty);

    test('launch page goes straight to onboarding, never the dashboard', () {
      expect(_redirect(fresh, '${Routes.launch}?from=%2F'), Routes.onboarding);
    });

    test('any other screen goes to onboarding', () {
      expect(_redirect(fresh, Routes.practice), Routes.onboarding);
      expect(_redirect(fresh, Routes.onboarding), isNull);
    });
  });

  group('returning learner', () {
    const loaded = AsyncData(_done);

    test('launch page continues to the original destination', () {
      final from = Uri.encodeComponent(Routes.studyPlan);
      expect(
        _redirect(loaded, '${Routes.launch}?from=$from'),
        Routes.studyPlan,
      );
    });

    test('launch page without a usable destination goes to the dashboard', () {
      expect(_redirect(loaded, Routes.launch), Routes.dashboard);
      final self = Uri.encodeComponent(Routes.launch);
      expect(
        _redirect(loaded, '${Routes.launch}?from=$self'),
        Routes.dashboard,
      );
      expect(
        _redirect(loaded, '${Routes.launch}?from=https%3A%2F%2Fx.y'),
        Routes.dashboard,
      );
    });

    test('onboarding is skipped and other screens are left alone', () {
      expect(_redirect(loaded, Routes.onboarding), Routes.dashboard);
      expect(_redirect(loaded, Routes.dashboard), isNull);
    });

    test('a background reload does not bounce to the launch page', () {
      const reloading = AsyncLoading<LearnerProfile>();
      final value = reloading.copyWithPrevious(loaded);
      expect(_redirect(value, Routes.dashboard), isNull);
    });
  });

  test('a failed profile load never strands the learner on launch', () {
    final failed = AsyncError<LearnerProfile>(
      StateError('db'),
      StackTrace.empty,
    );
    expect(_redirect(failed, '${Routes.launch}?from=%2F'), Routes.dashboard);
    expect(_redirect(failed, Routes.dashboard), isNull);
  });
}
