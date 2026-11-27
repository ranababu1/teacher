import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Static checks on the iOS project. The iOS build itself runs on macOS in
// .github/workflows/ios.yml; these catch config drift on any machine.

String _read(String path) => File(path).readAsStringSync();

/// Value of a top-level `<key>` in a plist, for simple string/bool values.
String? _plistValue(String plist, String key) {
  final m = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*<(string>([^<]*)</string|true|false)\\s*/?>',
  ).firstMatch(plist);
  if (m == null) return null;
  return m.group(2) ?? m.group(1);
}

void main() {
  final pbxproj = _read('ios/Runner.xcodeproj/project.pbxproj');
  final infoPlist = _read('ios/Runner/Info.plist');

  test('iOS bundle id equals the Android application id', () {
    final gradle = _read('android/app/build.gradle.kts');
    final appId = RegExp(r'applicationId\s*=\s*"([^"]+)"')
        .firstMatch(gradle)!
        .group(1)!;
    expect(appId, 'dev.imrn.teacher');

    final ids = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
        .allMatches(pbxproj)
        .map((m) => m.group(1)!)
        .toList();
    expect(ids.where((id) => id == appId), hasLength(3));
    expect(ids.where((id) => id == '$appId.RunnerTests'), hasLength(3));
    expect(pbxproj, isNot(contains('com.example')));
  });

  test('display name, encryption flag and deployment target', () {
    expect(_plistValue(infoPlist, 'CFBundleDisplayName'), 'Teacher');
    expect(_plistValue(infoPlist, 'CFBundleName'), 'Teacher');
    expect(_plistValue(infoPlist, 'ITSAppUsesNonExemptEncryption'), 'false');
    final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);')
        .allMatches(pbxproj)
        .map((m) => m.group(1))
        .toSet();
    expect(targets, {'15.0'});
  });

  test('privacy manifest is bundled and declares no tracking', () {
    final manifest = _read('ios/Runner/PrivacyInfo.xcprivacy');
    expect(_plistValue(manifest, 'NSPrivacyTracking'), 'false');
    expect(manifest, contains('NSPrivacyCollectedDataTypeCrashData'));
    expect(
      pbxproj,
      contains('/* PrivacyInfo.xcprivacy in Resources */,'),
      reason: 'PrivacyInfo.xcprivacy must be in the Runner Resources phase',
    );
  });

  test('app icons are opaque PNGs (App Store rejects alpha)', () {
    final icons = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList();
    expect(icons, isNotEmpty);
    for (final icon in icons) {
      final bytes = icon.readAsBytesSync();
      // IHDR colour type at byte 25: 2 = RGB (no alpha), 6 = RGBA.
      expect(bytes[25], 2, reason: icon.path);
    }
  });
}
