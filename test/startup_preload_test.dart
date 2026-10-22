import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/app/startup.dart';
import 'package:teacher/features/profile/domain/models/learner_profile.dart';
import 'package:teacher/features/profile/presentation/providers/profile_providers.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';
import 'package:teacher/features/settings/presentation/providers/settings_providers.dart';

class _Settings extends SettingsController {
  _Settings(this._value);
  final Future<AppSettings> _value;
  @override
  Future<AppSettings> build() => _value;
}

class _Profile extends LearnerProfileController {
  _Profile(this._value);
  final Future<LearnerProfile> _value;
  @override
  Future<LearnerProfile> build() => _value;
}

ProviderContainer _container(
  Future<AppSettings> settings,
  Future<LearnerProfile> profile,
) {
  final c = ProviderContainer(
    overrides: [
      settingsControllerProvider.overrideWith(() => _Settings(settings)),
      learnerProfileControllerProvider.overrideWith(() => _Profile(profile)),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('theme and profile are ready before the first frame', () async {
    final c = _container(
      Future.value(AppSettings.defaults.copyWith(themeModeKey: 'dark')),
      Future.value(LearnerProfile.empty),
    );
    await preloadStartupState(c);
    expect(c.read(themeModeProvider).name, 'dark');
    expect(c.read(learnerProfileControllerProvider).hasValue, isTrue);
  });

  test('a slow load times out instead of holding the splash', () async {
    final c = _container(
      Completer<AppSettings>().future,
      Future.value(LearnerProfile.empty),
    );
    final watch = Stopwatch()..start();
    await preloadStartupState(c, timeout: const Duration(milliseconds: 50));
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('a failed load does not throw', () async {
    final c = _container(
      Future.error(StateError('db')),
      Future.value(LearnerProfile.empty),
    );
    await expectLater(preloadStartupState(c), completes);
  });
}
