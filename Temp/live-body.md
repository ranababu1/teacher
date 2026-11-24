First public-release-ready build: a real application id, Firebase Crashlytics, safe Android auto-backup rules, and automated CI/CD.

### Changed
- **Application id is now `dev.imrn.teacher`** (reverse-DNS of
  teacher.imrn.dev), replacing the `com.example.teacher` placeholder in
  both `namespace` and `applicationId`, with `MainActivity.kt` moved to
  `kotlin/dev/imrn/teacher/` to match. Verified with `aapt dump badging`
  on the built APK. Android treats the id as permanent once published —
  never change it. Dev devices see this update as a fresh install
  (expected; no prior production users).
- **Release builds are log-quiet by design**: `AppLogger` drops
  `debug`/`info` in release (WARNING threshold) and prints plain
  single-line warnings/errors instead of boxed PrettyPrinter output.
  The opt-in "AI request logging" setting is additionally hard-disabled
  in release at the provider level, so AI request details can never be
  assembled on a user device.
- **Settings has a new "Privacy & Crash Reports" section**: a "Share
  crash reports" toggle (default on) that enables/disables Crashlytics
  collection live — the SDK persists the choice across restarts — plus
  a "Privacy policy" row opening teacher.imrn.dev/privacy in the system
  browser (url_launcher, with a copy-to-clipboard fallback). The
  Developer section (debug mode, AI request logging, test flash card
  button) is now hidden and tree-shaken out of release builds.

### Added
- **Firebase Crashlytics end-to-end** (project "teacher-max"): google-
  services 4.4.4 + crashlytics-gradle 3.0.7 (the exact pair firebase_core
  4.14.0 pins), firebase_core + firebase_crashlytics 5.3.0 Dart packages,
  a `CrashReportingService` wired in main.dart — FlutterError.onError
  (fatal) plus PlatformDispatcher.instance.onError (non-fatal) — and a
  debug-only "Trigger a test crash" tile in Settings for verifying the
  pipeline. Stack traces and device metadata only: no Analytics SDK, no
  user identifiers.
- **Android auto-backup is now explicit and safe**: allowBackup stays ON
  (it's the only data-loss protection for learner progress — the whole
  Drift database at app_flutter/teacher_db.sqlite is backed up), while new
  res/xml/backup_rules.xml (Android ≤11) and data_extraction_rules.xml
  (Android 12+, cloud-backup + device-transfer) exclude only the
  flutter_secure_storage files holding the device-bound encrypted API
  keys and their key material.
- **GitHub Actions CI** (.github/workflows/ci.yml): on every push/PR —
  `flutter analyze`, all 160 tests, and a debug APK build smoke test.
- **GitHub Actions Release** (.github/workflows/release.yml): pushing a
  `v*` tag runs analyze + tests, materializes signing from 4 repository
  secrets, builds an obfuscated universal APK + .aab, archives the Dart
  symbol files, and attaches the APK to a GitHub Release with
  auto-generated notes.

### Verification
- `flutter analyze`: no new issues (all 33 remaining are pre-existing
  info lints). `flutter test`: all 160 tests pass.
- `flutter build apk --release` succeeds; `aapt dump badging` confirms
  package `dev.imrn.teacher`, versionCode 20, versionName 0.16.0. The
  merged release manifest carries the backup-rule attributes and the new
  `dev.imrn.teacher.MainActivity`.

## Installing

Pick the file that matches your device:

- `teacher-arm64-v8a-r20.apk` — most modern phones (2018+)
- `teacher-armeabi-v7a-r20.apk` — older 32-bit phones
- `teacher-x86_64-r20.apk` — emulators / x86 devices
- `teacher-r20.apk` — universal APK (any device; largest)

Enable "Install from unknown sources" if prompted, then open the
downloaded APK. On a modern 64-bit phone the arm64-v8a file is the
smallest download (~26MB vs ~68MB universal).

> **Note**: this is the first build with the real application id
> `dev.imrn.teacher`. It installs as a fresh app - older
> `com.example.teacher` development builds are not upgraded in place and
> can be uninstalled afterward.

**Full Changelog**: https://github.com/ranababu1/teacher/compare/v0.15.0...v0.16.0

