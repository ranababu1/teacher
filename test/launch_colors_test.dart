import 'dart:convert';
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

  test('iOS launch screen uses the same light and dark colours', () {
    final json = jsonDecode(
      File('ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    Color? light;
    Color? dark;
    for (final entry in (json['colors'] as List).cast<Map<String, dynamic>>()) {
      final c = (entry['color'] as Map)['components'] as Map;
      int ch(String k) => int.parse((c[k] as String).substring(2), radix: 16);
      final color = Color.fromARGB(255, ch('red'), ch('green'), ch('blue'));
      final isDark =
          (entry['appearances'] as List?)?.any(
            (a) => (a as Map)['value'] == 'dark',
          ) ??
          false;
      if (isDark) {
        dark = color;
      } else {
        light = color;
      }
    }
    expect(light, AppColors.lightSurface);
    expect(dark, AppColors.darkSurface);

    final storyboard = File('ios/Runner/Base.lproj/LaunchScreen.storyboard')
        .readAsStringSync();
    expect(
      storyboard,
      contains('<color key="backgroundColor" name="LaunchBackground"/>'),
    );
  });
}
