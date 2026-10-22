import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/app/theme.dart';

const _res = 'android/app/src/main/res';

Color _launchColor(String valuesDir) {
  final xml = File('$_res/$valuesDir/colors.xml').readAsStringSync();
  final hex = RegExp(
    r'<color name="launch_background">#([0-9A-Fa-f]{8})</color>',
  ).firstMatch(xml)!.group(1)!;
  return Color(int.parse(hex, radix: 16));
}

void main() {
  test('native splash colours match the app background', () {
    expect(_launchColor('values'), AppColors.lightSurface);
    expect(_launchColor('values-night'), AppColors.darkSurface);
  });

  test('every launch theme and drawable uses the shared colour', () {
    for (final dir in [
      'values',
      'values-night',
      'values-v31',
      'values-night-v31',
    ]) {
      final styles = File('$_res/$dir/styles.xml').readAsStringSync();
      expect(styles, contains('@color/launch_background'), reason: dir);
      expect(styles, contains('@drawable/launch_background'), reason: dir);
      if (dir.endsWith('v31')) {
        expect(styles, contains('windowSplashScreenBackground'), reason: dir);
      }
    }
    for (final dir in ['drawable', 'drawable-v21']) {
      final drawable = File('$_res/$dir/launch_background.xml')
          .readAsStringSync();
      expect(drawable, contains('@color/launch_background'), reason: dir);
      expect(drawable, isNot(contains('@android:color/white')), reason: dir);
    }
  });
}
