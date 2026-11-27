# iOS release

How to turn `main` into a TestFlight build and then an App Store release.
Steps marked **Owner** need Imran's Apple account, Mac, iPhone or a decision.
Everything else is in the repository. Android releases are unchanged
(`.github/workflows/release.yml`).

Same approach as Arrowlock: the build is signed on Imran's Mac with Xcode's
automatic signing for Apple team `CW68Z23WQ4`; CI only proves that the
project compiles (unsigned) and needs no Apple secrets.

## 1. What is already set up

| Item | Where |
| --- | --- |
| Bundle id `dev.imrn.teacher` (same as Android), name "Teacher" | `ios/Runner.xcodeproj`, `ios/Runner/Info.plist` |
| Automatic signing, team `CW68Z23WQ4` | `DEVELOPMENT_TEAM` in the Runner target |
| iOS 15.0 minimum (Firebase needs 15; Xcode 26+ builds 15+) | `IPHONEOS_DEPLOYMENT_TARGET` |
| Plugins through Swift Package Manager (no CocoaPods, no Podfile) | `FlutterGeneratedPluginSwiftPackage` |
| App icons, opaque, 1024 marketing icon without alpha | `flutter_launcher_icons` (`remove_alpha_ios: true`) |
| Launch screen in the app surface colour (light/dark) | `LaunchScreen.storyboard`, `LaunchBackground` colour set |
| `ITSAppUsesNonExemptEncryption` = false (HTTPS only) | `Info.plist` |
| Privacy manifest | `ios/Runner/PrivacyInfo.xcprivacy` |
| Crashlytics when `GoogleService-Info.plist` is present | "Copy Firebase Config" build phase |
| No permission strings: the app uses no camera, photos, location, mic or tracking | `Info.plist` |
| Notifications ask for permission only when reminders are turned on | `flashcard_notification_service.dart` |
| Ads stay Android only (`AdService.isSupported`); the iOS SDK is linked but never started | `lib/features/ads/data/ad_service.dart` |
| Unsigned release build on every push | `.github/workflows/ios.yml` |
| Signed .ipa build and checks on the Mac | `tool/build_ios.sh` |

## 2. Firebase config (Owner, once)

1. https://console.firebase.google.com → project **teacher-max** → Project
   settings → Add app → **iOS**. Bundle ID `dev.imrn.teacher`, nickname
   "Teacher iOS". App Store ID can be added later.
2. Download **GoogleService-Info.plist** and save it as
   `ios/Runner/GoogleService-Info.plist`. Skip the SDK and init steps in the
   wizard; the project already does them.
3. Commit it (it is client config, not a secret, like
   `android/app/google-services.json`), or keep it only on the Mac.
4. Optional: Crashlytics → upload an APNs key is **not** needed (no push).

Without the file the app builds and runs, but without Crashlytics, and
`tool/build_ios.sh` refuses unless `--no-firebase` is passed.

## 3. Mac setup (Owner, once)

1. Xcode 26 or later from the Mac App Store, opened once to install
   components. `sudo xcode-select -s /Applications/Xcode.app`
2. Flutter 3.47.0 (same as CI): `flutter --version`.
3. Xcode → Settings → Accounts: the Apple ID of team `CW68Z23WQ4` (the one
   that published Arrowlock).
4. `git clone https://github.com/ranababu1/teacher && cd teacher`

## 4. Build

```
tool/build_ios.sh
```

It runs the analyzer and tests, `flutter build ios --release --config-only`,
archives with automatic signing (`-allowProvisioningUpdates`, so Xcode
creates the App Store profile for `dev.imrn.teacher` itself), exports
`build/teacher-<version>-b<build>.ipa`, and checks the bundle id, version,
build number, display name, encryption flag, privacy manifest, Firebase
config and signing team. It uploads Crashlytics dSYMs when Firebase is set
up. Nothing goes to Apple.

Version and build come from `pubspec.yaml` (`0.34.0+46` → version 0.34.0,
build 46). App Store Connect needs a higher build number for every upload.

**Own iPhone without TestFlight:** `open ios/Runner.xcworkspace`, pick the
iPhone, Run (turn on Developer Mode on the phone first).

## 5. App Store Connect and TestFlight (Owner)

1. https://appstoreconnect.apple.com → Apps → **+** → New App: iOS, name
   "Teacher" (or an available variant, max 30 characters), primary language
   English, bundle id `dev.imrn.teacher` (register it under Certificates,
   Identifiers & Profiles → Identifiers if it is not listed, or let the first
   `tool/build_ios.sh` run create it), SKU `teacher-ios`.
2. Upload the .ipa with **Transporter** (Mac App Store) or Xcode →
   Organizer → Distribute App.
3. TestFlight: the build shows after processing (10 to 30 minutes). Add
   yourself as an internal tester and install through the TestFlight app.
4. No submission for review without Imran's explicit go.

## 6. Listing (Owner, with agent drafts)

- Privacy policy URL: https://imrn.dev/products/teacher/privacy-policy
- Support URL: https://imrn.dev/products/teacher/support
- Category: Education. Price: Free.
- Screenshots: iPhone 6.9" (1320 × 2868) and, because the app runs on iPad,
  iPad 13" (2064 × 2752). Take them from the simulator or a device.
- App Privacy answers: crash data and diagnostics, not linked, not used for
  tracking (Crashlytics, only with "Share crash reports" on). AI questions go
  from the device straight to the provider the learner picked, with the
  learner's own API key, after the in-app consent. Check the answers against
  Xcode's Privacy Report of the archive (Organizer → archive → Generate
  Privacy Report), which merges the SDK manifests.
- Age rating questionnaire; export compliance is answered by the
  `ITSAppUsesNonExemptEncryption` key.
- Review notes: no account or sign-in is needed; AI features need the
  reviewer's own API key, everything else works offline.

## 7. Device checks (Owner, physical iPhone)

- [ ] Clean install opens without a white flash, in light and dark mode.
- [ ] Onboarding, a lesson (next/back steps, quick checks), resume after
      swiping the app away.
- [ ] Settings → flash card reminders on: iOS asks for notification
      permission; a test notification arrives and opens the card.
- [ ] Settings → Share crash reports: with Firebase set up, a Release build
      crash shows in Crashlytics within about 15 minutes.
- [ ] Dynamic Island and home bar do not cover content; rotation works.
- [ ] AI Teacher with a key: answer, Continue for long answers.
