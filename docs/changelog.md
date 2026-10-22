# Changelog

## 2026-10-22 (release: v0.25.0 - AI study coach)

### Added
- **Projects on the course screen**: each course's detail screen now lists
  its guided projects below the topics, with milestone progress or
  readiness, and opens the project on tap. Hidden when a course has none.
- **System design in your study plan**: learners on the System Design
  course get a design step: the first exercise not yet tried, otherwise the
  one with the lowest best score under 75%.
- **AI study coach capability** (Phase 5 "AI-generated personalized
  curriculum", groundwork): `AIProvider.coachStudyPlan` takes a learner
  summary, the app's ordered plan and the career goal, and returns a short
  assessment, a weekly focus and one tip per step. Implemented for Gemini
  and Anthropic (native JSON schemas) and OpenAI-compatible providers
  (DeepSeek, OpenAI) with the usual retry-once parsing; without an API key
  it fails with the standard "add a key" message. Prompt and provider tests
  included.
- **AI coach on the study plan**: an "Ask the AI Coach" card at the bottom
  of Your study plan. On tap (never automatically, since it uses your own
  API key) it sends only counts, titles, accuracy, the plan and your goal,
  then shows a short read on where you stand, a focus for the week, and a
  "Coach:" tip under each step. Missing keys or AI errors show the plain
  message with Try Again; the plan itself always works offline.

## 2026-10-22 (release: v0.24.0 - System design exercises)

### Added
- **System design exercises: content and storage** (Phase 5 "system design
  exercises"): six staged walkthroughs in
  `assets/system_design/exercises.json` (rate limiter, news feed, chat,
  notification service, distributed cache, file storage and sync). Each has
  a scenario, five stages (requirements, estimates, API and data model,
  high-level design, deep dive and trade-offs) with hints and a model
  answer, plus common pitfalls. Finished attempts are stored in a new
  `system_design_attempts` table (schema v5, additive). Tests cover the
  content, best-score records and a v3 to v5 upgrade.
- **System Design screens**, opened from a new Dashboard card: a list with
  difficulty, time and your best score, and a walkthrough screen that goes
  stage by stage. Read the scenario, reveal hints one at a time, write notes,
  reveal the model answer and rate yourself (Nailed it / Partly / Missed
  it). The summary shows your score, the stages to revisit and common
  pitfalls; the attempt is saved. Routes `/system-design` and
  `/system-design/:exerciseId`.

## 2026-10-22 (release: v0.23.0 - Personal study plan)

### Added
- **Your study plan** (Phase 4/5 "personalized learning paths" and
  "personalized curriculum"), opened from a new Dashboard card that previews
  the step count, total minutes and first step. Built offline from your own
  data, in priority order: due reviews, up to two weak concepts (from
  learning analytics), a topic test you are ready for (all lessons done, test
  not passed), the next lesson, a project milestone (in progress first, or a
  project whose recommended topic you passed), then a mock interview (2+
  topics passed) or a debugging session. At most six steps, each with a
  plain reason and a time estimate; tapping a step opens it. Shows your
  career goal when set. New learners get a single "pick your first course"
  step. Route `/plan`.

## 2026-10-22 (release: v0.22.0 - Guided projects)

### Added
- **Guided projects content and storage** (Phase 5/9 "projects", section 47):
  ten bundled multi-milestone projects in `assets/projects/projects.json`
  (Python, React, Java, Node, Go, system design, databases, Docker), each
  with a brief, milestones, a self-review rubric and stretch goals. Milestone
  completion is stored in a new `project_milestone_progress` table (schema
  v4, additive migration). Content and repository tests included.
- **Projects screens**, opened from a new Dashboard card: a list showing
  each project's course, difficulty, estimated hours and milestone progress
  (in progress first, then projects whose recommended topic you have passed,
  then the rest; finished ones last), and a project screen with the brief,
  a tickable milestone checklist, a self-review rubric and stretch goals.
  Routes `/projects` and `/projects/:projectId`; back retraces as usual.

## 2026-10-22 (release: v0.21.0 - Challenge Lab: debugging, coding and scenarios)

### Added
- **Challenge Lab** (Phase 9 "coding challenges, debugging sessions,
  scenario-based problems"), opened from a Dashboard card or the Practice
  screen's app-bar button. Pick a course, then one of: Debugging Sessions
  (358 bundled exercises across courses), Coding Challenges (68) or
  Real-World Scenarios (8). Each kind shows how many are available; empty
  kinds are disabled.
- **Challenge sets**: three challenges from different concepts where
  possible, easiest first, played with the standard exercise player
  (hints, model solution, AI check when configured, attempts recorded so
  mastery, review and analytics update). "New Set" draws again, "Done"
  goes back.
- Code: lib/features/challenges (ChallengeService, providers, two
  screens); routes `/challenges` and `/challenges/:pathId/:kind`; helpers
  `openChallengeLab`, `openChallengeSet`. Offline, content-driven, no new
  dependencies.

### Verification
- test/challenge_lab_test.dart (counts per kind, set size, distinct
  concepts and difficulty order, small and empty pools, kind parsing,
  lab and set widget states) and a navigation test for
  dashboard > lab > set > back x2. `flutter analyze --no-fatal-infos` no
  errors or warnings; `flutter test` 205 passing.
- Version bumped to 0.21.0+28 (r28).

## 2026-10-22 (release: v0.20.0 - learning analytics)

### Added
- **Learning analytics screen** (Phase 5 "learning analytics"), opened
  from a new "Learning analytics" card on the Progress tab. Built from
  real attempt history (the old Dashboard sparklines are decorative):
  - answers, active days in the last 28 days, usual study time;
  - a 28-day activity chart (bar height = answers per day, filled part =
    answers that met the success bar);
  - accuracy for each of the last four 7-day windows;
  - accuracy and answer count per course;
  - up to five weak spots (concepts tried at least twice and below
    100%, lowest first), each opening its lesson;
  - answers by part of the day.
  "Success" uses the same bar as the Progress screen (attempt quality
  >= 0.6). Empty state until the first answer.
- Code: lib/features/analytics (pure LearningAnalyticsService, provider
  with an injectable clock); route `/analytics`, helper `openAnalytics`.
  Theme colours only; no new dependencies, no schema change.

### Verification
- test/learning_analytics_test.dart (empty history; daily, weekly,
  course, weak-spot and day-part maths incl. old and unknown attempts;
  widget content and empty state) and a navigation test for
  progress > analytics > back. `flutter analyze --no-fatal-infos` no
  errors or warnings; `flutter test` 199 passing.
- Version bumped to 0.20.0+27 (r27).

## 2026-10-22 (release: v0.19.0 - interview prep: mock interviews with model answers)

### Added
- **Interview prep** (Phase 5 "interview preparation", section 48): a new
  screen, opened from a Dashboard card or the Practice screen's app-bar
  button, lists every course with interview questions. They come from the
  bundled explanation and scenario assessments that have a model answer
  (offline, no AI). This covers system design too, through the
  System Design course.
- **Mock interview session**: five questions per session, at most two
  real-world scenarios, the rest from different topics. For each
  question: optional answer notes (not saved), "Reveal Model Answer",
  then a self-rating (Nailed it / Partly / Missed it). The summary shows
  a score (2/1/0 points per question) and a "Worth revisiting" list that
  opens the related lesson; "New Session" draws a fresh set, "Done"
  goes back.
- Code: lib/features/interview (InterviewService, InterviewSummary,
  providers); routes `/interview` and `/interview/:pathId`; helpers
  `openInterviewPrep`, `openInterviewSession`. Nothing is persisted.

### Verification
- test/interview_test.dart (question bank filtering, session mix and
  size, scoring and revisit list, widget flow, empty state) and a
  navigation test for dashboard > interview > session > back x2.
  `flutter analyze --no-fatal-infos` no errors or warnings;
  `flutter test` 195 passing.
- Version bumped to 0.19.0+26 (r26).

## 2026-10-22 (release: v0.18.0 - skill check: find where to start in a course)

### Added
- **Course skill check** (Phase 5 "skill assessments"): every course with
  more than one topic shows "Already know some of this? Take a 5-minute
  skill check" on its detail screen. It samples the bundled
  multiple-choice assessments, offline and without AI: two per topic for
  courses with up to 8 topics, otherwise one per topic, capped at 16 and
  spread evenly across the course. Each question can be answered or
  skipped with "I don't know".
- **Results and placement**: overall score, a per-topic breakdown, and a
  "Where to start" recommendation. The leading run of topics answered
  perfectly can be skipped. A topic that was not asked, or any miss, stops
  the run, so a learner is never moved past unchecked material. "Unlock N
  topics" starts the course if needed and records those topics as passed
  (score 100), which opens the recommended topic under the normal
  topic-test gate; "Go to ..." then replaces the skill check with that
  topic, so back returns to the course.
- Code: lib/features/skill_check (SkillCheckService builds and scores,
  ApplySkillCheckPlacementUseCase writes through the existing progress
  repositories, providers bump dataRevision). Route
  `/learn/:pathId/skill-check` (declared before `:moduleId`), helper
  `openSkillCheck`. No database schema change.

### Verification
- test/skill_check_test.dart (question sampling for short, long and empty
  courses; scoring and placement rules; placement writes against an
  in-memory database; widget flow for answer, skip, results, unlock; empty
  state) and a navigation test that the skill-check URL is not taken by
  the topic route. `flutter analyze --no-fatal-infos` no errors or
  warnings; `flutter test` 188 passing.
- Version bumped to 0.18.0+25 (r25).

## 2026-10-15 (release: v0.17.2 - bigger app icon)

### Changed
- **Book is much bigger in the app icon** (tool/make_icon.py): about 79%
  of the foreground width (was 49%), in both app_icon_foreground.png and
  app_icon_full.png (legacy Android and iOS). Feedback from a Galaxy
  home screen: One UI showed the book at about half the icon width next
  to Steam, so the icon looked padded and small. One UI's squircle is
  now filled; pure circle masks trim the book's corners slightly
  (accepted). Note: launchers that crop adaptive icons to the 72dp
  viewport (e.g. Pixel) may also clip the book's left and right edges.
- Regenerated all Android and iOS launcher icons with
  `dart run flutter_launcher_icons`.
- Version bumped to 0.17.2+24 (r24).

## 2026-10-14 (release: v0.17.1 - new app icon)

### Changed
- **New app icon**: a glossy pink/violet open book on a soft lavender
  gradient, from the artwork the user supplied (kept at
  assets/icon/source/teacher_icon_reference.png).
- **New icon pipeline**: `python3 tool/make_icon.py` (numpy, pillow,
  scipy) builds the three 1024x1024 sources: app_icon_background.png
  (full-bleed vertical gradient fitted to the reference, #FFFFFD to
  #DBDEED), app_icon_foreground.png (transparent; book cut out with a
  colour-distance mask, closed/hole-filled, edge anti-aliased at 4x;
  LANCZOS upscale on premultiplied alpha; 49% of the layer width so its
  diagonal fits the 66dp adaptive safe circle) and app_icon_full.png
  (composite, square corners). `dart run flutter_launcher_icons`
  regenerated all Android mipmaps/adaptive layers and iOS AppIcon sizes.
- Removed the old books-stack generator test/_generate_icon.dart and its
  test/icon outputs; pubspec comment points to the new script. No in-app
  or splash usage of the icon besides the launcher icon (the
  flash-card notification uses @mipmap/ic_launcher, so it updates too).
- Version bumped to 0.17.1+23 (r23).

## 2026-10-14 (release: v0.17.0 - linear navigation: back always returns to the previous screen)

### Changed
- **Back always returns to the previous screen** (1 > 2 > 3, back
  3 > 2 > 1). Root cause: most moves used `context.go`, which rebuilds the
  stack from the URL hierarchy instead of from what the learner visited,
  mixed with a few `push` calls, so back skipped, looped through finished
  pages, or jumped tabs.
- **New lib/app/navigation.dart** (`AppNavigation` extension) holds the
  rules in one place; screens call `openLesson`, `openTopic`,
  `openTopicTest`, `openLearningPath`, `openPractice(Session)`,
  `openReview(Session)`, `openSettings`, `goBack`, `replaceWithNextTopic`,
  `continueFromTestToNextTopic`, `switchToTab` instead of raw go/push.
  Drill-downs, shortcuts and detours push; Back/Done buttons pop (same as
  system back); `go` remains only for onboarding finish, the flash-card
  fallback, tab switches and cold-start fallbacks.
- **Route tree (lib/app/router.dart)**: the shell now has only the four
  visible tabs (Dashboard, Learn, Progress, Profile; the wide-screen rail
  matches). Path, topic, test, lesson, Practice, Review, their sessions
  and Settings are top-level routes on the root navigator, so a push from
  any tab stacks on top and back returns there. URLs are unchanged except
  Settings, now `/settings`; the old `/profile/settings` redirects. A cold
  deep link builds its parent pages; back from the bottom-most one goes
  to Dashboard instead of exiting. Route builders are injectable
  (`AppScreens`, `buildAppRoutes`) for tests.
- **Completion**: a passed test's "Continue to Next Topic" closes the test
  and replaces the finished topic, so back goes to the learning path; the
  topic page's "Continue" also replaces. Failed test / last topic /
  practice round "Back to Topic" pops. Lesson "Back to topic" is now
  "Back" (pops to wherever the lesson was opened from). Practice session
  gained a "Done" button (pops); Review session "Done" pops.
- **Detours**: "Go to Settings" from the AI panel and the practice session
  push Settings on top; back returns to the lesson or practice. Practice
  and Review opened from Dashboard are full screens with a back arrow.
  Prerequisite chips and the locked-topic button push.

### Verification
- test/navigation_back_order_test.dart (11 tests, real route tree with
  stand-in screens, Android system back via handlePopRoute): dashboard >
  continue lesson > back; learn > path > topic > lesson > back x3;
  lesson > settings > back; prerequisite chip; test fail and pass exits;
  topic Continue; practice done/back; profile > settings; legacy settings
  URL; cold-start deep link back chain.
- Flutter 3.47.0: `flutter analyze --no-fatal-infos` no errors or
  warnings; `flutter test` 177 passing.
- Version bumped to 0.17.0+22 (r22).

## 2026-10-13 (release: v0.16.1 - crash fixes: safe Firebase startup, flash-card recovery)

### Fixed
- **Firebase startup can no longer crash the app**
  (lib/core/services/crash_reporting_service.dart, lib/main.dart):
  `Firebase.initializeApp()` is now wrapped in try/catch. On failure
  (broken google-services config, Play services missing, plugin error)
  the error is logged as a warning, `isAvailable` stays false, and the
  app starts normally without crash reporting. All other Crashlytics
  calls were already guarded by `_initialized`. Test seams
  (`initializeFirebase`, `isSupportedPlatform`) are `@visibleForTesting`.
  Tests: test/crash_reporting_service_test.dart.
- **Flash-card screen no longer crashes without its card data**
  (lib/app/router.dart, lib/features/flashcards/...): the route used
  `state.extra as FlashCard`, which throws when `extra` is lost (process
  restore, deep link). New `FlashCard.tryParse` accepts a card, its JSON
  map, or a JSON string and returns null otherwise; the route then shows
  a friendly `FlashCardUnavailableScreen` ("This flash card is no longer
  available" + "Back to Teacher"). Closing either screen pops if
  possible, else goes to the dashboard (no dead end when the card is the
  first route).
- **Notification taps that launch the app from a terminated state now
  open the card**: `initialize()` reads
  `getNotificationAppLaunchDetails()` (that tap never fires
  `onDidReceiveNotificationResponse`), and `openCardFromPayload` waits
  frame by frame (up to 120 frames) for the root navigator to mount
  instead of silently dropping the tap. Malformed payloads are logged
  and ignored. Tests: test/flash_card_route_test.dart.

### Changed
- **Release publishes only two APKs** (.github/workflows/release.yml):
  `teacher-arm64-v8a-rNN.apk` (most modern phones (2018+)) and the
  universal `teacher-rNN.apk` (universal APK (any device)). The
  armeabi-v7a and x86_64 assets are dropped; the split build now uses
  `--target-platform android-arm64`, and the download guide and asset
  labels match. Signing from repo secrets, .aab and symbol artifacts are
  unchanged.
- Version bumped to 0.16.1+21 (r21).

### Verification
- Flutter 3.47.0: `flutter pub get`, `flutter analyze --no-fatal-infos`
  (no errors or warnings), `flutter test` (all 166 tests pass).

## 2026-09-09 (release assets: per-ABI APKs restored; v0.16.0 retrofitted)

### Changed
- **Release workflow publishes per-ABI APKs again** (.github/workflows/
  release.yml): alongside the universal APK it builds `--split-per-abi`
  variants and attaches four files to each GitHub Release, named like
  the hand-published releases up to v0.15.0 — `teacher-arm64-v8a-rNN.apk`
  (~26MB), `teacher-armeabi-v7a-rNN.apk` (~23MB), `teacher-x86_64-rNN.apk`
  (~27MB), `teacher-rNN.apk` (universal, ~68MB). rNN is the versionCode
  from pubspec.yaml (0.16.0+20 → r20, 0.17.0+21 → r21), extracted with
  sed in the workflow. Every asset gets a device label ("most modern
  phones (2018+)" etc.) via `gh api`, and the release notes get a
  "Which file should I download?" guide ahead of the auto-generated
  changelog. Motivation: the universal APK is ~70MB; a modern phone
  (e.g. Galaxy S25 Ultra) only needs the ~26MB arm64-v8a build.
- **Hyphenated tags publish as pre-releases automatically**
  (`prerelease: ${{ contains(github.ref_name, '-') }}`; verified in
  softprops/action-gh-release source that the string 'false' parses as
  boolean false), so rc/beta rehearsal tags can never take the "Latest"
  badge.
- **v0.16.0 release retrofitted to the four-file layout**: built the
  three split APKs locally with the same upload keystore (apksigner:
  V2 signer, CN=Imranul Haque Mazumder; versionCode 2020 = 2000 + 20
  ABI offset, so it installs as an in-place update over the universal
  versionCode 20), uploaded them, renamed the existing universal asset
  `teacher-v0.16.0.apk` → `teacher-r20.apk`, set the four device
  labels, and updated the notes' Installing section to the file list.

### Verification
- End-to-end rehearsal on a disposable tag: pushed `v0.17.0-rc1`
  (then deleted release + tag) → Release run 34270602318 green; the
  created pre-release had exactly the four correctly-named APKs with
  labels, prerelease=true, and the guide + Full Changelog body with no
  duplication. CI on the main push (34270597882) and on the tag
  (34270602312) also green.
- Note: GitHub auto-attaches "Source code (zip/tar.gz)" links to every
  release; there is no setting to remove them. They are generated on
  demand from the tag and are not real assets, so they stay.

### Git
- Commit: 0801024 (ci(release): publish per-ABI APKs alongside the
  universal APK (rNN naming, device labels, download guide))
## 2026-09-08 (release: v0.16.0 — public-release hardening: real app id, crash reporting, backup rules, CI/CD)

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
  `flutter analyze --no-fatal-infos`, all 160 tests, and a debug APK
  build smoke test. (Learned the hard way: `flutter analyze` exits 1 on
  info-level issues by default — the first two CI runs failed on the 33
  pre-existing info lints before this flag was added; errors and
  warnings still fail the run.)
- **GitHub Actions Release** (.github/workflows/release.yml): pushing a
  `v*` tag runs analyze + tests, materializes signing from 4 repository
  secrets, builds an obfuscated universal APK + .aab, archives the Dart
  symbol files, and attaches the APK to a GitHub Release with
  auto-generated notes. `build.gradle.kts` reads android/key.properties
  when present and falls back to the debug keystore otherwise, so local
  release builds keep working before the real keystore exists. Signing
  material can never leak into the repository: .gitignore now
  hard-blocks android/key.properties and any *.jks / *.keystore files.

### Verification
- `flutter analyze`: no new issues (all 33 remaining are pre-existing
  info lints). `flutter test`: all 160 tests pass.
- `flutter build apk --release` succeeds (72s); `aapt dump badging`
  confirms package `dev.imrn.teacher`, versionCode 20, versionName
  0.16.0. The merged release manifest carries the backup-rule
  attributes and the new `dev.imrn.teacher.MainActivity`.
- **v0.16.0 published end-to-end**: CI run green on GitHub Actions
  (analyze, 160 tests, debug APK on the runner), then the tag-triggered
  Release workflow built the signed obfuscated APK (70.7 MB, attached
  as teacher-v0.16.0.apk) + .aab, archived the Dart symbols
  (release-symbols-v0.16.0, 90 days), and created the GitHub Release
  with changelog-derived notes. Signing came from the 4 repo secrets —
  .gitignore confirmed blocking key.properties/*.jks from the repo.
  Post-tag fix on main: release.yml now also archives the signed .aab
  as a workflow artifact (its header comment always promised this;
  v0.16.0's run predates the step).
- Known forward-looking warning, no action yet: Flutter flags that
  firebase_core/firebase_crashlytics/flutter_timezone still apply the
  Kotlin Gradle Plugin; a future Flutter may refuse until those plugins
  ship Built-in Kotlin support.

## 2026-09-01 (release: v0.15.0 — new icon, collectible badges, skill tiers, faster startup)

### Changed
- **New app icon**: a stack of five books in a cream/magenta/peach/
  lavender/mauve palette, replacing the graduation cap — regenerated
  through the existing `test/_generate_icon.dart` +
  `flutter_launcher_icons` pipeline for every Android/iOS resolution.
- **Achievements grew from 8 to 21 collectibles** across 6 categories
  (streak, XP/level, lessons, courses, coding, and two new quiz-based
  categories), each with a flavorful name and its concrete criterion
  shown underneath (e.g. "On Fire" / "7 day streak"). Achievements now
  render as a medallion grid instead of plain text chips. The streak
  stat's label now explicitly says "N day streak."
- **"My Skills" now only lists a course once it's at least 50%
  complete**, and each shows a status badge next to its name — "In
  Progress" while under 100%, then "Passed"/"Expert"/"Legend" once
  complete, graded off the average score across that course's passed
  topic quizzes.

### Fixed
- **App startup no longer blocks the UI thread on ~11MB of curriculum
  JSON.** Every module file across all 16 subjects now reads
  concurrently instead of one at a time, and the actual `jsonDecode`
  step runs in a background isolate (`compute()`) instead of on the UI
  thread — same data, same error handling, just off the thread that
  was causing jank right after launch.

### Verification
- `flutter analyze`: no new issues. `flutter test`: all 160 tests pass
  (2 new tests for the extended badge roster).
- Live-verified on the emulator: new icon renders correctly on the
  home screen/app-info page; seeded real progress/mastery/quiz-score
  data directly into the on-device database (student_progress +
  concept_mastery + module_test_progress tables) to exercise both new
  features end-to-end — a 60%-complete course correctly shows "In
  Progress," a 100%-complete course with all-100% quiz scores shows
  "Legend," and seven new badges unlocked and rendered correctly in the
  new grid. Curriculum content loaded correctly across two full app
  reinstalls after the startup-performance change, with no regressions.

## 2026-08-24 (release: v0.14.1 — hero card cleanup, generous XP)

### Changed
- **Dashboard hero card simplified**: dropped the description subtitle
  and the separate "Continue"/"Browse Learning Paths" CTA button
  (removed the button widget entirely, now unused) — the card is just
  an eyebrow chip, the lesson/state title, and the photo. The whole
  card was already one tap target, so it stays fully clickable with
  noticeably less visual clutter.
- **XP is now awarded far more generously, with new tiers**: opening
  the app (+25 XP, once per calendar day — new `AppOpenRepository`,
  can't be farmed by force-stopping/reopening), completing a full topic
  i.e. every concept in a module (+400 XP, new), and passing a topic's
  quiz/module test (+600 XP, new). Existing tiers were bumped up too:
  exercise attempts 10→20 (+15→25 bonus), assessment attempts 20→40
  (+30→50 bonus), lesson (concept) completion 100→250, course
  completion 500→2000. `ExperienceLevel`'s tier thresholds are scaled
  ~4x so the leveling curve keeps roughly the same pacing under the
  bigger numbers.

### Verification
- `flutter analyze`: no new issues. `flutter test`: all 156 tests pass
  (2 new XP-tier tests added).
- Live-verified on the emulator: hero card renders title+photo only and
  still navigates on tap; a fresh app open shows exactly 25 XP with no
  other activity, and force-stopping + relaunching within the same day
  leaves it at exactly 25 XP (confirms the once-per-day guard holds,
  not a double-award).

## 2026-08-24 (release: v0.14.0 — Statistics learning path)

### Added
- **New "Statistics" course** — 14 modules, 76 concepts, going from
  absolute first principles (sample spaces, Bayes' theorem) through to
  research-adjacent depth (variational inference/ELBO, VC dimension,
  statistical learning theory), explicitly framed for ML engineers.
  Modules: Foundational Probability Theory, Random Variables &
  Probability Distributions, Standard Probability Distributions, Limit
  Theorems & Asymptotic Theory, Descriptive Statistics & EDA, Sampling &
  Parameter Estimation, Hypothesis Testing Framework, Parametric &
  Non-Parametric Statistical Tests, Information Theory, Regression &
  Linear Modeling Statistics, Multivariate Statistics & Dimensionality
  Reduction, Bayesian Statistics & Probabilistic Graphical Models,
  Stochastic Processes & Time Series Statistics, and Statistical
  Learning Theory & Model Validation.
- Every concept explicitly ties the abstract math back to ML practice —
  e.g. cross-entropy loss derived as KL divergence which is derived as
  MLE; Ridge/Lasso regularization derived as MAP estimation under a
  Gaussian/Laplace prior; PCA tied to embedding dimensionality
  reduction; bootstrapping tied to model-uncertainty estimates.
- 203 multiple-choice questions across the course (comfortably clearing
  the existing 10-per-module gating-test minimum in every module), plus
  152 exercises and 76 free-response "explain it back" assessments.
- New "statistics" subject icon (`Icons.query_stats_outlined`); its
  identity color needed no code changes since colors are already
  hash-derived per subject id.

### Verification
- Authored by 14 parallel background agents (one per module) against
  the app's real `Concept`/`Assessment`/`Exercise` JSON schema, each
  independently executing and re-deriving its own embedded Python/numpy/
  scipy code before finalizing — this caught and fixed several genuine
  arithmetic and library-compatibility errors during authoring (not
  simulated; verified against a real Python 3.13 / numpy 2.5 / scipy
  1.18 / scikit-learn 1.9 environment). All 3 agents that hit a
  transient API/connection error had already written valid, complete
  files before dropping — confirmed via a full independent re-validation
  pass rather than assumed.
- A second, independent Node.js structural validator (unique ids across
  all 431 exercises/assessments, required fields present, MCQ counts,
  valid in-file prerequisite references, no placeholder tokens) passed
  with zero errors across all 14 files.
- `flutter analyze`: no new issues. `flutter test`: all 154 tests pass.
- Live-verified end to end on the emulator: selected Statistics during
  onboarding, confirmed it appears with the correct icon/color/difficulty
  in the subject picker and Learning Paths grid, confirmed the Dashboard
  hero card resolves to the course's actual first concept, opened the
  full path detail screen (correct module ordering, module-lock gating
  intact for module 2+), and opened the first lesson to confirm markdown
  formatting, inline math notation, and syntax-highlighted code blocks
  all render correctly for this course's content.

## 2026-08-18 (release: v0.13.1 — glass UI refinements)

### Changed
- **App-wide type scale bumped ~4px** across every `TextTheme` role
  (`displaySmall` 36→40 down to `labelSmall` 11→15, with proportional
  line-height/spacing adjustments) plus a few hardcoded sizes that don't
  read from the theme (bottom-nav labels, code-block monospace text,
  inline markdown code, the Profile streak-badge emoji) — the glass
  redesign's default Material 3 scale read too small on-device.
- **Hero card redesigned** to match the reference mockups exactly: the
  previous full-bleed purple gradient wash is gone in favor of a neutral
  glass card with an eyebrow chip, a gradient-tail headline (only the
  last word/phrase is gradient-filled), a solid gradient CTA button, and
  a real photo in a swoop-clipped corner — sourced from Pexels (search:
  "man glasses studying tablet") since this app bundles no photography
  by design (`assets/images/hero_photo.jpg`, resized/compressed to ~11KB
  before bundling).

### Fixed
- **Back gesture/button no longer exits the app from other tabs.** Each
  bottom-nav tab is its own independent navigation stack
  (`StatefulShellRoute.indexedStack`), so once a tab's own back-stack was
  exhausted, the system back action had nowhere left to go but "exit app"
  — even when the user arrived at that tab via a Dashboard shortcut and
  never explicitly asked to leave the app. Wrapped the shell in a
  `PopScope` that redirects to Dashboard instead of exiting whenever the
  active tab isn't Dashboard and its own stack is empty; intra-tab back
  navigation (e.g. Lesson → Topic → Course → Learning Paths) is
  unaffected since it's fully consumed by that tab's own `Navigator`
  before this ever triggers. Live-verified with a 4-tap back trace from
  Dashboard → Lesson → Topic → Course → Learning Paths → **Dashboard**
  (previously: → exits to the home screen).
- **Learning Paths cards no longer overflow** ("BOTTOM OVERFLOWED BY
  1.00 PIXELS") — a direct side effect of the type-scale bump outgrowing
  the grid's fixed card height; `mainAxisExtent`/skeleton `itemHeight`
  raised from 190 to 222.
- Continuing to a sibling module/topic from Module Detail's or Module
  Test's "Continue" button now uses `context.push()` instead of
  `context.go()` — `go()` to a same-depth sibling route replaces the
  entire branch stack, so swiping back from the next module used to skip
  straight past it to the course/topic detail screen instead of landing
  back on the module just finished.

### Verification
- `flutter analyze`: no issues in touched files.
- `flutter test`: all 154 tests pass.
- Live-verified on the emulator in both light and dark mode: typography
  legibility, hero card visual match to the reference mockups, the full
  back-gesture trace above, and the Learning Paths grid with zero
  overflow.

## 2026-08-18 (release: v0.13.0 — Liquid Glass redesign)

### Changed
- **Whole-app visual redesign** in an iOS 26 "Liquid Glass" style: every
  card app-wide is now a translucent, frosted glass surface
  (`GradientCard`, rewritten in place — real blur reserved for exactly
  one or two "featured" surfaces per screen, everywhere else fakes the
  glass look with translucency + a gradient edge highlight + a shadow,
  so ordinary lists never pay for a dozen simultaneous GPU blur passes).
  Every app bar is now a matching frosted `GlassAppBar`. The bottom
  navigation is now a floating glass pill with a solid indicator badge
  on the active tab (a lighter glass tint on the tablet/desktop rail).
  The existing brand colors, gradients, and font (Atkinson Hyperlegible)
  are unchanged — this is a material/surface change, not a rebrand.
- **Dashboard restructuring**: the hero card now carries an abstract
  gradient-blob accent (this app has no photography/3D-render assets by
  design, so that replaces the reference mockup's photo); the old
  progress-bar list and practice-queue card are replaced by a 3-tile
  stat row (course progress, concepts ready, day streak — the streak
  stat is newly surfaced on the Dashboard from an existing Profile-screen
  provider) with small decorative sparklines; and a new "Continue your
  journey" section shows a step-dot card per started course. Recommended
  Next is now a second dark-glass featured card with a glass medallion
  icon and an explicit "Start Learning" button.
- Live-verified in both light and dark mode across every touched screen
  on the emulator (Dashboard, Learn list/detail/module/lesson, Practice
  list/session, Progress, Profile, Settings, Module Test) with zero
  layout exceptions. One real layout crash was caught and fixed during
  this pass: a stat-row `Row` using `crossAxisAlignment.stretch` with no
  bounded-height ancestor was throwing "BoxConstraints forces an infinite
  height" and silently blanking the whole Dashboard — fixed with
  `IntrinsicHeight`.

## 2026-08-18 (release: v0.12.0 — static-first topic tests, AI practice rounds, curriculum content expansion)

### Changed
- **Topic-gating test is now static-first, always**: the required test to
  unlock the next topic no longer depends on AI generation at all — it
  always draws from that topic's own curated static question bank, so
  passing is deterministic and doesn't depend on AI availability or an
  AI provider's output quality. (Previously: AI-generated when a
  provider was configured, with a shorter static fallback otherwise.)
- **New optional AI practice round**: once a topic test is passed, a
  learner with an AI provider configured can tap "Practice More (20 AI
  Questions)" for a fresh, larger AI-generated set — purely extra
  practice, never persisted, and never re-gates or re-locks anything
  already earned. Live-verified: the button is correctly absent with no
  AI configured, appears once one is, makes a real request, and a bad
  key surfaces a clean inline error ("Your Gemini API key isn't
  working...") without disrupting the passed state.

### Added
- **Curriculum content expansion**: every one of the 99 module files
  across all 15 subjects now has at least 10 multiple-choice questions
  (most had exactly 1 per concept before, ~3 per module). ~950 new
  questions were authored, each grounded in that concept's own
  explanation/examples/misconceptions content rather than generic
  trivia, matching the depth and style of the existing questions.
  Verified programmatically after authoring: 0 modules below 10, 0
  duplicate assessment ids, 0 malformed options/correctOptionIndex
  across all 1136 total multiple-choice questions.

## 2026-08-17 (release: v0.11.0 — topic-gated testing, model management, dashboard redesign)

### Added
- **Topic-gated testing**: advancing from one topic (module) to the next
  now requires passing a gating test at ≥70%, instead of every course
  concept's tests being dumped onto the Dashboard immediately on start.
  AI-generated on demand (≥10 multiple-choice questions covering every
  concept in the topic, generated via a new 6th `AIProvider` capability
  — `generateModuleTest` — implemented across all 4 providers); falls
  back to a shorter test built from the topic's existing static
  assessment questions when no AI provider is configured, still gated
  at 70%. New `ModuleTestScreen` (intro → one MCQ at a time with instant
  local grading → pass/fail result), new `ModuleTestProgressTable` (with
  a migration backfill so nobody already mid-course gets retroactively
  locked out of a topic they'd already started), and lock UI on both
  the course detail grid and the topic detail screen. Removed the old
  "Pending Tests" Dashboard card, which nagged about every un-attempted
  assessment across the whole course at once — tests now surface
  exactly where and when they're earned.
- **Per-provider model selection and custom models**: Settings gained a
  "Model" dropdown next to the AI provider picker, plus a manage-models
  dialog to add/rename/remove custom model ids per provider. The
  built-in default model per provider stays protected (locked, never
  editable/removable) so it can't be emptied out and stays current with
  future app updates.
- **Cost-effective AI defaults**: OpenAI now defaults to `gpt-5.6-luna`
  (confirmed live against OpenAI's current docs as the cost-optimized
  tier) and DeepSeek to `deepseek-v4-flash` (DeepSeek's `deepseek-chat`
  is no longer the documented primary model name). Gemini and Claude
  were already on their cost-effective defaults.
- **Dashboard visual polish**: a new subtle corner-gradient sheen
  (`GradientCard`) applied to every ordinary Dashboard card, and two new
  widgets that fill the previously-empty mid/bottom of the Dashboard
  before any course is started — a big-number curriculum snapshot
  (courses/concepts/hours, computed live, never hardcoded) and a
  3-tile "why Teacher" benefits row. Both disappear the instant a
  course starts.

### Fixed
- A real, live-caught routing bug: go_router tries sibling routes in
  declaration order, so the new topic-test route was being swallowed by
  the pre-existing `:conceptId` wildcard sibling (matching `.../test` as
  a concept lookup) for every single topic, not just ones with a
  concept literally named "test." Fixed by declaring the static route
  first.

Verified: `flutter analyze` and the full test suite (152 tests, 20+ of
them new) pass. Live-verified on the emulator end to end: the full
topic-gating flow (locked → take test → fail → retry with a reshuffled
question set → pass → next topic unlocks and stays unlocked after an
app restart) with no AI configured; the per-provider model
dropdown/manage-models dialog (added, selected, and removed a custom
Claude model, confirmed the selected model string reaches the real
Anthropic API, confirmed removing a selected model falls back to the
baseline default); the Dashboard gradient cards and empty-state filler
content in both light and dark themes, confirmed they disappear once a
course starts.

## 2026-08-17 (release: v0.10.1 — fix all AI network calls on real devices)

### Fixed
- **`android.permission.INTERNET` was never declared in `AndroidManifest.xml`**
  — present since the very first commit (`c19038b`), not a regression.
  Without it, every outbound HTTP call (Gemini, and now OpenAI/Anthropic/
  DeepSeek) is refused at the OS socket layer before any request is sent;
  Dio surfaces that as a connection error, which every provider's error
  classifier reports as "You're offline" — even on a fully connected
  device, and near-instantly since no real network attempt ever happens.
  This had gone unnoticed because prior testing was emulator-only, where
  Android's permission enforcement is looser; a real OnePlus device
  surfaced it immediately. Fixed by adding the permission declaration.
  Live-verified on the real device with genuine API keys after the fix:
  Gemini, Claude, and DeepSeek's "Test AI Connection" all now report "AI
  Teacher is working correctly" instead of failing instantly.

## 2026-08-17 (release: v0.10.0 — multi-provider AI support)

### Added
- **OpenAI, Anthropic Claude, and DeepSeek as AI providers**, alongside
  the existing Gemini support. A new "AI provider" dropdown in Settings
  (`AiProviderKind` enum, persisted via the existing generic
  `SettingsTable` key-value pattern) selects which backend powers the AI
  Teacher, exercise generation, and connection testing; each provider
  keeps its own API key in secure storage
  (`SecureApiKeyStore.storageKeys`), so switching providers never clears
  or overwrites another provider's saved key. Existing installs keep
  their already-stored Gemini key working unchanged — the storage key
  literal (`gemini_api_key`) was preserved exactly.
- DeepSeek reuses OpenAI's Chat Completions wire format via one shared
  `OpenAiCompatibleProvider`/`OpenAiCompatibleApiClient`, distinguished
  only by base URL, model, and a `providerLabel` used in error text — no
  duplicated implementation.
- Anthropic's implementation uses `output_config.format.json_schema`
  (standard JSON Schema, not Gemini's OpenAPI subset) and explicitly
  handles a `stop_reason: "refusal"` response (a safety-classifier
  decline that returns HTTP 200 with empty `content`) as a clean
  `AIUnavailableException` instead of crashing on an empty array.
- Refactored the previously Gemini-only prompt-building and strict
  JSON-field-parsing logic into shared, provider-agnostic modules
  (`shared_prompt_builder.dart`, `ai_response_parsing.dart`) reused by
  all four providers — a behavior-preserving extraction verified by
  running Gemini's existing test suite unmodified against the retrofit.

Verified: `flutter analyze` and the full test suite (119 tests, including
new `openai_provider_test.dart`, `anthropic_provider_test.dart`, and
`secure_api_key_store_test.dart`) pass. Live-verified on the emulator:
the Settings dropdown switches cleanly between all 4 providers with
fully independent key/test state per provider (entered a key for Claude,
switched to Gemini and back — no leakage either direction); the AI
Teacher panel's "not configured" hint correctly names whichever provider
is currently selected (confirmed with OpenAI); "Test AI Connection"
against a real (invalid) Claude key exercised the live network/error
path without crashing. Not yet live-verified: an actual successful AI
response from OpenAI, Anthropic, or DeepSeek with a genuine key — no
such key was available this session. Gemini's existing behavior is
unchanged and was not re-verified beyond its passing test suite.

## 2026-08-16 (release: v0.9.0 — guided first-run + dashboard scoping fixes)

### Added
- **"What do you want to learn?" onboarding step**: `OnboardingScreen`
  becomes a 2-step flow (still one `/onboarding` route, no router
  changes) — name/goal as before, then a multi-select subject picker
  sourced from `learningPathsProvider`, reusing the Learn tab's
  icon/color/difficulty treatment (`subjectColor`/`subjectIcon`,
  `DifficultyChip`). Coming-Soon (zero-module) paths render dimmed and
  unselectable, matching the rest of the app's existing rule that such
  paths can never be started. Picking one or more subjects calls the
  existing `LearningPathStarter` for each — the same "Start Course"
  plumbing used elsewhere — before completing onboarding. The single
  primary button reads "Skip for now" with nothing selected, "Get
  Started" once ≥1 subject is picked.

### Fixed
- **Continue Learning no longer contradicts a just-started course**:
  `ContinueLearningService.resolve()` previously fell back to a
  generic "pick a learning path to get started" CTA whenever zero
  `StudentProgress` rows existed, even for a learner who'd explicitly
  started a path (e.g. via the new onboarding step) but hadn't opened a
  lesson yet. It now checks started-path status first and points at
  that path's first concept instead.
- **Recommended Next no longer ignores the explicit-start gate**:
  `dashboardRecommendationProvider` was calling `RecommendationService`
  over every curriculum path regardless of started status, so it could
  surface a concept from a path the learner never started — contradicting
  the app's own gate on unstarted-path lessons. Now scoped to started
  paths only.
- **No more duplicate "Continue Learning" / "Recommended Next" cards**:
  right after onboarding, both could independently resolve to the same
  "first concept of the started path" before any mastery data exists.
  Recommended Next is now suppressed specifically when it matches what
  Continue Learning is already showing; it stays visible in every other
  case, where the two legitimately diverge.

Live-verified end to end on the emulator, twice from a fresh install:
selecting Python + Databases in onboarding immediately started both
(Learning Progress/Practice/Pending Tests all reflected 58 combined
concepts) and the Dashboard's Continue Learning card showed a real
concept with no duplicate Recommended Next card; skipping the subject
picker with zero selections landed cleanly on the original empty-state
dashboard.

## 2026-08-16 (release: v0.8.0 — onboarding, gamification, and Profile)

### Added
- **First-launch onboarding**: a new install now shows a one-time
  `OnboardingScreen` (name required, career goal optional) before ever
  reaching the Dashboard, gated via a `redirect` + `refreshListenable`
  bridge from go_router to a new `LearnerProfile` (backed by the existing
  generic `SettingsTable`, no new Drift table/migration). Never shown
  again once completed — live-verified: fresh install -> onboarding ->
  Dashboard, relaunch skips straight to Dashboard.
- **Personalized Dashboard greeting**: the static "Teacher" app bar and
  time-of-day greeting are replaced with "Hi {name} 👋 / Ready to
  continue learning?", sourced from the learner's profile.
- **Streak, XP, and badges** (`lib/features/profile/domain/`):
  `StreakService` (current + longest streak, local-calendar-day based),
  `XpCalculator` (10/20 XP per exercise/assessment attempt +15/30 quality
  bonus, 100 XP per concept completed, 500 XP per course completed —
  counting only each item's first chronological attempt so resubmitting
  an already-solved item can't be farmed for more points), a 5-tier
  `ExperienceLevel`, and an 8-badge `BadgeEvaluator` across
  course/streak/coding/lesson milestones. Streak badges use *longest*
  streak, not current streak, so they don't disappear the day after a
  streak breaks. All derived live from existing attempt/progress data —
  nothing new is persisted beyond the profile itself.
- **Profile tab**: replaces Settings as the 4th phone tab / 6th rail
  destination (net-zero tab count, no overflow) — avatar, name,
  experience level, streak/XP, Learning Progress stats, Achievements
  badges, My Learning Goals (tap to edit career goal; daily target from
  existing settings), My Skills (per-course mastery bars), and a
  Settings section. Settings itself is unchanged, now reached via a gear
  icon nested at `/profile/settings` (back returns to Profile).
- **Pending Tests dashboard card**: a new self-hiding card showing
  concepts (in started courses) with an assessment but no recorded
  attempt yet, computed directly from attempts rather than
  `StudentProgress.isCompleted` so it can't silently break if that
  field's completion rule ever changes.
- Two small shared-logic extractions (pure refactors, no behavior
  change): `firstIncompleteConcept`/`isPathCompleted` out of
  `ContinueLearningService`, and `qualityOf` out of
  `learningStatsProvider` — both now reused by the new profile stats so
  "is this path done" / "was this attempt any good" can't silently
  drift into two different answers.

Live-verified end to end on the emulator: onboarding flow, personalized
greeting, starting a course and seeing Pending Tests populate/route
correctly, completing a practice exercise and watching XP (25 = 10 base
+ 15 quality bonus) and skill mastery update live on the Profile screen,
and the Profile tab/Settings nesting with correct back-navigation.

## 2026-08-16 (release: v0.7.0 — release-prep pass: course gating, dashboard logic, navigation, redesign)

### Added
- **Course-start hard gate**: a learning path's lessons can't be opened at
  all until its explicit "Start Course" button is tapped — modules render
  dimmed with a lock icon until then. New `learning_path_progress` Drift
  table + migration (schema v1 -> v2, the app's first-ever migration),
  backfilling "started" for any path with pre-existing concept-level
  progress so upgrading never locks a learner out of something they'd
  already begun (caught via live testing on the emulator's real data).
  Guards added at `LearningPathDetailScreen`, `ModuleDetailScreen`, and
  `LessonScreen` (the last also fixed to bump `dataRevisionProvider` on
  `markStarted`, a latent staleness bug found along the way).
- **Continue Learning rewrite**: now a sealed `ContinueLearningState`
  instead of a nullable `Concept?` — resumes the last incomplete concept,
  advances to the next incomplete one in the same path once the most
  recent is finished (scanning the whole path to catch out-of-order
  completion gaps), and shows a distinct "You've completed X!" card when
  the entire path is done — never a stale placeholder, never a silent
  fallback to the unrelated recommendation engine.
- **Progress filtering**: Dashboard's Learning Progress list and the
  standalone Progress screen now only show started courses (via a new
  `startedPathProgressSummariesProvider`), instead of all 15 seeded paths
  at 0%. The Learning Paths catalog screen intentionally keeps showing
  everything.
- **Practice course selector**: a dropdown scoped to started courses
  replaces the old flat list mixing every course's exercises together.
- **Bottom nav**: phones drop from 6 to 4 always-labeled destinations
  (Dashboard, Learn, Progress, Settings) — the prior 6 overflowed/cramped
  on phone widths. Practice and Review become Dashboard cards (mirroring
  the existing review-queue card) on phones, and stay full tabs on the
  wide-screen rail.
- **Visual redesign** (deliberately different axes than the 2026-08-14
  pass — no new gradients): tiered `AppElevation` replaces flat
  everything-is-elevation-0 cards; a per-subject color+icon system
  (`subjectColor`/`subjectIcon`) derived from the curriculum's existing
  `iconName` field, wired into progress bars, difficulty chips (which now
  finally use the long-defined `success`/`warning`/`danger` colors), and
  a new 2-column Learning Paths grid replacing the 15-row flat list; a
  bumped/tightened `headlineMedium` for the Dashboard greeting; a new
  `SectionLabel` widget (small, uppercase, muted) replacing plain
  `titleMedium` section headers; hand-rolled skeleton loading states
  (no new package) on every list screen.

### Verification
- `flutter analyze`: clean throughout (only pre-existing style-info lints
  shared with other code in the codebase).
- `flutter test`: all 76 tests pass, including new coverage for
  `ContinueLearningService` and `LearningPathProgressRepositoryImpl`.
- Live-verified on the emulator end to end: the full gate flow (locked ->
  Start -> unlocked -> lesson content), the migration backfill (caught
  and fixed the pre-existing-progress lockout bug this way), Continue
  Learning advancing past a completed concept, Progress/Dashboard
  filtering to started paths only, the Practice dropdown switching
  between courses, the 4-tab phone nav with Practice/Review reachable via
  dashboard cards, and the full visual redesign (grid, subject colors,
  elevation, typography) with no layout overflow.

### Git
- 12 small commits, each analyzed/tested and pushed immediately:
  `185de03`, `400dd23`, `779e918`, `78c16bc`, `b1ca84e`, `74cefb3`,
  `b13cd49`, `5f292f4`, `4000ee9`, `e825dfa`, `1c9bfa3`, plus this
  version bump.
- Tag: `v0.7.0` (see below for release creation).

## 2026-08-16 (release: v0.6.0 — Weekly Flash Cards, instructions.md §36)

### Added
- Full weekly-flashcard implementation, replacing the previously inert
  settings toggle:
  - Content pool built from concepts opened in the last 7 days
    (`GenerateWeeklyFlashcardsUseCase`), using their already-authored
    misconceptions and first explanation section — never AI-generated or
    static placeholder content, keeping the feature fully
    offline-capable.
  - `FlashcardSchedulePlanner`: pure, unit-tested logic for computing a
    day's notification times from the volume (low/medium/high ->
    2/4/8 per day) and frequency mode (random within waking hours 8am-
    10pm, or user-fixed times) settings.
  - `FlashcardNotificationService`: wraps `flutter_local_notifications`,
    plans a rolling 7-day window of notifications, cycling through the
    card pool. Deliberately uses inexact scheduling and skips the
    lockscreen-takeover `fullScreenIntent` — a review nudge, not an
    alarm, so neither the exact-alarm nor full-screen-intent special
    permissions are requested. "Full screen" instead describes the
    in-app card view's ad-free, chrome-free layout.
  - New Settings controls: daily volume and frequency dropdowns, a
    chip-based fixed-time editor, and a Developer-only "send test
    notification" action to verify the tap-to-open flow on demand.
  - Schedule (re)plans automatically on app startup and whenever a
    flashcard-relevant setting changes.
- New dependencies: `flutter_local_notifications`, `timezone`,
  `flutter_timezone`. Android manifest: `POST_NOTIFICATIONS` +
  `RECEIVE_BOOT_COMPLETED` permissions and the two
  flutter_local_notifications receivers for reboot-survival; core
  library desugaring enabled (required by the plugin).

### Verification
- `flutter analyze`: clean (only pre-existing style-info lints shared
  with other use cases in the codebase).
- `flutter test`: all 66 tests pass, including new coverage for the
  content-selection use case and the schedule planner.
- Live-verified end to end on the emulator: enabled the feature, granted
  the Android 13+ notification permission (dialog appeared and was
  handled correctly), confirmed via `dumpsys alarm` that a real rolling
  week of `RTC_WAKEUP` alarms was scheduled across multiple days at
  varied times matching the medium/random settings, sent a test
  notification, confirmed it posted via `dumpsys notification`, tapped
  it, and confirmed the full-screen card view opened with the right
  content, revealed its answer, and closed cleanly back to the app.
- Noted but not chased further: a faint horizontal color-banding
  artifact appeared partway down the flash card screen in two
  screenshots during verification. Functionally harmless (didn't
  recur, didn't block any interaction) — possibly an emulator
  screenshot-capture quirk like the one documented for screencap
  corruption after long uptime. Worth a second look if a user ever
  reports it visually on a real device.

### Git
- Commits: `a99eb26`, `b0d1e07`, `176f5ed`, `6e31ef1`, `ca1ac83`,
  `f658822`, `e4fa86b`, `00ec2e5` (one small logical unit each, each
  pushed immediately).
- Tag: `v0.6.0` (see below for release creation).

All notable changes to Teacher are logged here, most recent first. This file
is local/personal (gitignored alongside `instructions.md`) and exists to give
every new session fast context on what was built, why, and what's next —
per the workflow in `instructions.md` §69.

## 2026-08-15 (release: v0.5.1 — live real-device diagnosis)

### Verified live on the user's physical device (CPH2619, Android 16, OPPO/ColorOS)
- User reported "Test AI" instantly saying no internet despite a green
  connectivity indicator, on real hardware (this never reproduced on the
  emulator). Connected the phone via adb and diagnosed directly rather than
  guessing further.
- Ruled out, with hard evidence gathered from the device itself: OS-level
  connectivity (ping to `generativelanguage.googleapis.com` succeeded,
  12-25ms), raw HTTPS/TLS reachability (`curl` to the exact Gemini endpoint
  succeeded in ~150-180ms over both IPv4 and IPv6), any HTTP proxy (none
  configured), any VPN/firewall app (none installed), standard Android
  Data Saver/background-network policy (app was unrestricted), and app
  config (baseUrl/model are hardcoded constants, unaffected by build type).
- Installed a temporary debug build (versioned `0.5.0+9999` so it could
  update-install without wiping the user's saved API key/progress) because
  release builds aren't debuggable on this ROM and their `AppLogger`
  output never reaches `adb logcat` — confirmed empirically: identical
  failure on the release build produced zero matching log lines across all
  logcat buffers, even with the ring buffer widened to 16MB and captured
  immediately after the event.
- With the debug build's logs visible, caught the real cause directly:
  a genuine Gemini-side `HTTP 503 UNAVAILABLE` ("This model is currently
  experiencing high demand"). Retried once more and it succeeded ("AI
  Teacher is working correctly."). This is the 6th genuine transient
  Gemini 503 hit across this project's testing — not a bug, expected
  occasional behavior of `gemini-3.7-flash` under load.
- Conclusion: the `isOnlineProvider` short-circuit bug (see prior entry)
  was the real, fixable defect; today's live reproduction attempts
  otherwise hit real transient Gemini overload, which the app already
  reports correctly and specifically ("Google's AI service is temporarily
  busy. Try again in a moment.").
- New technique learned: `adb install -r -d` (allow downgrade) was refused
  outright on this device/Android version even with `-d` — the only way
  to move a debug diagnostic build onto a device already running a higher
  versionCode release, without wiping data, was bumping the diagnostic
  build's version number above the installed one, then reverting in the
  repo afterward without committing the throwaway number.

### Added
- Bumped version to `0.5.1+6` for the sixth release.

### Git
- Commit: (see below)

## 2026-08-15 (fix: Test AI Connection false-negative on real devices)

### Fixed
- `ApiKeySection._testConnection()` was short-circuiting on
  `isOnlineProvider` (OS link-layer status via `connectivity_plus`) *before*
  attempting any real Gemini call, immediately reporting "No internet
  connection" without a network round-trip if that heuristic read `false`.
  On a real device (unlike the emulator's stable virtual NIC), that signal
  can flip to `none` for a brief moment — WiFi power-save/roam checks,
  mobile radio idling between requests, a missed connectivity broadcast
  under battery/Doze restrictions — even seconds after the Settings dot
  showed green. Reported by the user: v0.5.0 installed on a real phone,
  "Test AI" instantly says no internet despite a green indicator.
- Fix: removed the pre-flight gate entirely. The button always attempts the
  real `testConnection()` round-trip now; a genuinely offline device still
  gets an accurate "You're offline" result, sourced from the actual failed
  Dio connection attempt (`NetworkUnavailableException`), not a guess.
- Confirmed via grep that no other AI entry point (`teach`/`assess`/
  `evaluateExplanation`/`generateExercise`) shared this gate — only the Test
  button had it, so this was an isolated diagnostic-feature bug, not a
  defect in the core AI flow.

### Verification
- `flutter analyze` on the edited file: no issues.
- `flutter test`: all 56 tests pass.
- Not yet re-verified live on the user's physical device (no adb access to
  it in this session — only the emulator is attached). Emulator's virtual
  NIC doesn't reproduce the flap that triggered this, so this fix is
  code-reasoned + unit-verified, not live-reproduced end to end.

### Git
- Commit: (see below)

## 2026-08-15 (release: v0.5.0)

### Added
- Bumped version to `0.5.0+5` for the fifth release: "Know why AI isn't
  working" — the connectivity indicator + AI diagnostics feature below.

### Git
- Tag: `v0.5.0`
- Pushed to GitHub: yes

## 2026-08-15 (connectivity indicator + AI diagnostics)

User reported real confusion when AI failed: no way to tell "internet is
down" from "AI-specific problem," and the error message was the same
generic string regardless of cause. Fixed as 4 small, independently
pushed increments per the git workflow directive (feedback earlier this
session: previous "one commit per vertical slice" cadence was still too
coarse — each of these 4 units is its own commit+push, no batching):

### Added
- Live green/red connectivity dot in Settings' AI Provider section
  (`connectivity_plus`, `core/services/connectivity_provider.dart`) —
  updates in real time as the device's network state changes, confirmed
  by toggling WiFi/mobile data via `adb shell svc wifi/data` mid-session
  and watching the dot flip without touching the app.
- `gemini_error_classifier.dart`: turns Gemini's canonical error status
  (`UNAUTHENTICATED`, `PERMISSION_DENIED`, `RESOURCE_EXHAUSTED`,
  `UNAVAILABLE`, etc.) — or the HTTP status code as a fallback — into a
  specific, plain-language message. Every existing AI error surface
  (lesson panel, exercise grading, exercise generation) benefits
  automatically since they all just render `AppException.userMessage`.
- `AIProvider.testConnection()` + `TestAiConnectionUseCase` + a "Test AI
  Connection" button in Settings: a real minimal Gemini round trip that
  reports exactly what's wrong — no internet, bad API key, rate limited,
  Google's servers busy, or working — short-circuiting to "no internet"
  immediately (no wasted network timeout) when the connectivity indicator
  already knows that's the cause.

### Verification
- flutter analyze: passed. flutter test: passed (56/56 across all 4
  units).
- Live on-device, all 4 units combined: confirmed the connectivity dot
  flips red/green in real time with WiFi/data toggled via adb; confirmed
  "Test AI Connection" reports "AI Teacher is working correctly" with a
  real valid key; confirmed it short-circuits to "No internet connection"
  instantly when offline, with no network attempt; confirmed it correctly
  reports "Your Gemini API key isn't working" when a real Gemini call
  rejected a deliberately invalid key; and — twice more, independently —
  reproduced the same genuine transient Gemini 503 seen earlier this
  session, both times correctly classified as "Google's AI service is
  temporarily busy," both times resolved on retry.
- Hit an unrelated emulator flake mid-session: after very long uptime,
  `adb exec-out screencap` started returning a corrupted/blank frame for
  the app's content area even though the app itself was confirmed running
  and fully drawn (checked via `dumpsys window`/logcat, no crash). Fixed
  by `adb reboot`-ing the emulator's OS (not the app) — this is emulator
  tooling flakiness, not an app bug; if screenshots go blank/garbled after
  hours of the same emulator instance running, reboot it before assuming
  the app broke.

### Git
- 4 commits, each pushed immediately: connectivity indicator, error
  classification, `testConnection` capability, Settings UI wiring.

## 2026-08-15 (release: v0.4.0)

### Added
- Bumped version to `0.4.0+4` for the fourth release: "AI Teacher (Gemini integration)". Covers all three Phase 3 slices from today (Gemini provider + ask-a-question panel, AI-graded exercise feedback + dynamic misconceptions, AI-generated practice exercises).

### Git
- Tag: `v0.4.0`
- Pushed to GitHub: yes

## 2026-08-15 (Phase 3 slice C: AI-generated practice exercises)

### Added
- `GenerateExerciseUseCase`: calls `AIProvider.generateExercise` with the
  same assembled `TeachingContext` as every other AI Teacher capability,
  and reuses `Exercise.fromJson` as-is to parse the result — no new
  parsing logic needed since the Gemini response schema was already built
  to match that shape in slice A.
- `PracticeSessionScreen` (converted to `ConsumerStatefulWidget`): a
  "Generate a fresh exercise" action below the concept's static
  exercises. Generated exercises play through the exact same
  `ExercisePlayer` as curriculum content, visually tagged "AI-generated"
  (tertiary-colored label) so it's never mistaken for trusted curriculum
  per sections 55-56 — and never persisted back into it, only kept in
  this screen's local state for the session. Shows a compact "add a
  Gemini key" hint when AI isn't configured, and a retryable error banner
  on failure, consistent with the rest of the AI Teacher UI.

### Verification
- `flutter analyze`: passed (same pre-existing info-level hints).
- `flutter test`: passed (46/46) — new: a `GenerateExerciseUseCase` test
  in `ai_teacher_use_cases_test.dart` asserting the returned exercise and
  the context passed to the fake `AIProvider`.
- Live on-device verification with a real Gemini key: tapped "Generate a
  fresh exercise" on a Python concept whose only static exercise was a
  "Debugging" item — got a genuine (transient) HTTP 503 first, which
  rendered the same retryable error banner pattern used elsewhere, then
  on retry received and played a novel, well-formed "Predict the Output"
  exercise (testing function-definition-vs-execution-order) through the
  unmodified `ExercisePlayer`, correctly labeled "AI-generated" and
  visually distinct from the static exercise above it.

### Git
- Pushed to GitHub: yes

## 2026-08-15 (Phase 3 slice B: AI-graded feedback + dynamic misconceptions)

### Added
- `TeachingContextBuilder`: extracted from `TeachUseCase` so context
  assembly can't drift between it and two new use cases —
  `AssessUseCase` (grades short-answer/scenario/debugging/coding
  responses via `AIProvider.assess`) and `EvaluateExplanationUseCase`
  (grades "explain in your own words" responses via
  `.evaluateExplanation`, tracking `isComplete` separately from
  `isCorrect`). Both persist every AI-detected misconception via
  `MisconceptionRepository`.
- `ExercisePlayer`: self-assessed exercises (everything except MCQ) now
  have an "Ask AI to check this" action alongside — never replacing —
  the existing reveal-and-self-rate flow, so offline learners keep full
  functionality per section 26. On a correct/incorrect verdict from the
  AI, the attempt is recorded with `isCorrect` from that verdict instead
  of a self-rating, and the AI's feedback renders inline (markdown,
  correctness + completeness badges). A failed grading call shows a
  compact retryable error banner without losing the typed answer.
- `lesson_screen.dart`'s `_MisconceptionsSection` now also shows
  unresolved AI-detected misconceptions for the concept (distinct
  tertiary-tinted card, "Flagged by the AI teacher during a recent
  conversation"), not just the static curriculum-authored ones — the
  first thing that makes section 18's misconception detection dynamic
  end to end, from detection through to display.

### Verification
- `flutter analyze`: passed (same pre-existing info-level hints).
- `flutter test`: passed (45/45) — new: `ai_teacher_use_cases_test.dart`
  (6 tests: context assembly, missing-concept error, and both new use
  cases' misconception-persistence behavior with a fake `AIProvider`).
- Live on-device verification with a real Gemini key: submitted a
  deliberately flawed "explain in your own words" answer (echoing the
  curriculum's own "static is a performance optimization" misconception)
  through "Ask AI to check this" — got back a correct "Not quite ·
  Incomplete" verdict whose feedback named the exact planted
  misconception and explained the real JVM-bootstrap reason. Confirmed
  via `adb exec-out run-as ... cat teacher_db.sqlite` + the `sqlite3` CLI
  (same technique as 2026-08-13) that the misconception was actually
  persisted (`resolved_at` NULL) and the attempt row recorded
  `is_correct=0` with the learner's verbatim answer — then confirmed the
  same misconception now renders in the lesson's "Common Misconceptions"
  section in its distinct AI-flagged style.

### Git
- Pushed to GitHub: yes

## 2026-08-15 (Phase 3 slice A: Gemini-backed AI Teacher)

### Added
- First real `AIProvider` implementation: `GeminiProvider`, backed by Gemini's
  `generateContent` REST API (`gemini-3.7-flash`, confirmed against
  ai.google.dev — 1M token input, structured-JSON `responseSchema` support).
  `GeminiApiClient` sends the API key via the `x-goog-api-key` header (never
  a URL query param), decodes Gemini's double-encoded JSON envelope, and
  maps Dio failures to the existing `NetworkUnavailableException` /
  `AIUnavailableException` / `InvalidAIResponseException` hierarchy — a
  response that fails to parse is retried exactly once before giving up.
- `gemini_prompt_builder.dart`: pure prompt construction for all four
  `AIProvider` capabilities (teach/assess/generateExercise/
  evaluateExplanation), encoding the section 21 teaching principles (no
  fake encouragement, progressive hints, name misconceptions explicitly)
  and varying verbosity by the learner's `explanationDepth` setting — the
  first thing that setting actually does.
- `TeachUseCase`: assembles a `TeachingContext` (concept, prerequisites, all
  6 mastery scores, a 1-7 difficulty estimate, recent unresolved
  misconceptions) from the existing curriculum/mastery repositories, per
  section 20 — never sends an isolated question to the AI.
- `MisconceptionRepository` / `MisconceptionRepositoryImpl`: first real
  repository over the `misconceptions` table (already registered in
  `AppDatabase` but unused until now) — makes misconception detection
  dynamic per section 18, not just curriculum-authored. Named
  `DetectedMisconception` to avoid colliding with the curriculum's static
  `Misconception` model.
- "Ask the AI Teacher" panel in the Lesson screen: a conversation thread
  (`AiConversationController`, ephemeral/in-memory per concept) with an
  optimistic learner bubble, a thinking indicator, and — critically — a
  recoverable inline error state (`ConversationMessage.isError`) that never
  discards the conversation or the learner's question on failure. Shows a
  clear "needs a Gemini API key" card with a Settings shortcut when AI
  isn't configured, satisfying section 26's "UI must clearly communicate AI
  availability" (previously not implemented).
- `AppConfig.geminiApiBaseUrl` / `.geminiModel`: the endpoint/model live in
  one config object, not hardcoded in `GeminiProvider`.
- AI error logging: `GeminiApiClient` now logs the mapped exception (status
  code + response body, never the API key) via `AppLogger.error` on every
  Dio failure — closes a section 38 gap (AI errors previously weren't
  logged at all). `AppSettings.aiRequestLogging` now actually gates
  request-metadata logging in `TeachUseCase`, closing a second dead-setting
  gap.

### Verification
- `flutter analyze`: passed (same pre-existing `prefer_initializing_formals`
  info hints as before, now also present in the new files for consistency
  with the existing codebase style).
- `flutter test`: passed (39/39) — new coverage: `gemini_prompt_builder_test.dart`
  (9 tests, pure prompt-shape assertions), `gemini_provider_test.dart` (6
  tests against a faked `Dio` adapter — success parsing, HTTP error →
  `AIUnavailableException`, malformed/missing-key JSON → retry-once →
  `InvalidAIResponseException`, connection error → `NetworkUnavailableException`),
  `misconception_repository_test.dart` (7 tests against an in-memory Drift
  database via `AppDatabase.forTesting(NativeDatabase.memory())` — first
  repository-test convention in this codebase).
- Live on-device verification on the Android emulator with a real Gemini
  API key entered through Settings: confirmed the not-configured card,
  optimistic send + thinking state, a transient real HTTP 503 ("model
  experiencing high demand") correctly surfaced as a recoverable error
  bubble with a working "Try again" that resent the original question, and
  — on retry — a genuine Gemini response rendering with correct markdown
  (headings, numbered lists, inline code) and content clearly grounded in
  the lesson's actual context (referenced the specific class/method names
  from the concept being viewed). Also confirmed removing the key correctly
  reverts the panel to the not-configured card with no crash.
- Generated via 3 parallel background agents (Gemini data layer,
  misconception repository, AI teacher conversation UI/controller) working
  against fixed `AIProvider`/`TeachingContext` contracts with no shared
  files; integration (`TeachUseCase`, provider wiring, Lesson screen hookup)
  and all verification done directly by the orchestrating session, not
  trusted from agent self-report.

### Git
- Pushed to GitHub: yes

## 2026-08-14 (release: v0.3.0)

### Added
- Bumped version to `0.3.0+3`.
- Built and published GitHub release `v0.3.0` ("Full 15-subject curriculum")
  with 4 APKs (universal + arm64-v8a/armeabi-v7a/x86_64 splits), each
  suffixed `-r3` per the user's requested naming convention
  (`teacher-r3.apk`, `teacher-arm64-v8a-r3.apk`, etc.) so future releases
  read as `-r4`, `-r5`, ... at a glance.

### Process note
- User flagged that both curriculum waves (this session) landed as one
  commit each covering all 13 subjects, instead of one commit per subject
  as they land — a "bulk" pattern instructions.md §69 explicitly says to
  avoid. Root cause: commits were made only after the *entire* wave of
  parallel agents finished validating, not as each subject cleared
  verification. Fix going forward: commit+push per subject (or per
  meaningful sub-unit) as soon as it's independently verified, even when
  multiple agents are running in parallel — don't wait for the full batch.

### Git
- Tag: `v0.3.0`
- Pushed to GitHub: yes

## 2026-08-14 (wave 2: 4 more modules per placeholder subject)

### Added
- Quadrupled the depth of all 13 wave-1 subjects (Java, Spring Boot, Node.js,
  Go, Databases & PostgreSQL, Vector Databases, AI/ML, LLM Engineering,
  Docker, Kubernetes, System Design, Cloud/AWS, DevOps): each went from 2
  modules (6 concepts, ~5h) to 6 modules (17-18 concepts, ~14-16h) at the
  same depth bar as Python/React. User feedback: "i think the curriculum
  isnt complete... i can see only 2 modules per new course."
- Generated via 26 parallel isolated background agents (2 per subject,
  3-4 modules each), hitting the platform's 20-concurrent-subagent cap —
  the remaining 6 queued automatically as slots freed up, no manual
  intervention needed beyond re-launching the queued ones.
- Each pair of agents per subject was told to Read the existing module
  files first (for style/tone continuity and id-collision avoidance) and
  to check for the other agent's concurrent output before finishing, since
  both agents in a pair write to the same subject folder simultaneously.
- `assets/curriculum/manifest.json` updated for all 13 subjects:
  `moduleFiles` expanded from 2 to 6 entries each, `estimatedHours` recomputed
  from actual concept-minute sums (14-16h per subject, using the same ~1.3x
  buffer already implicit in Python's/React's manifest estimates).

### Verification
- Every one of the 26 agents' output was independently re-validated (not
  trusted from self-report): JSON parses, schema shape, placeholder-token
  sweep, and per-subject + global concept-id uniqueness — all 52 new files
  clean, zero id collisions across the entire curriculum (99 module files,
  15 subjects).
- Every module file referenced by manifest.json (99 total) confirmed to
  exist and parse — simulates the app's loader end to end.
- flutter analyze: passed (same 4 pre-existing unrelated info-level hints)
- flutter test: passed (17/17)
- Live on-device verification on the Android emulator: rebuilt the debug
  APK, confirmed via logcat there are no curriculum-loading errors, and
  confirmed visually (screenshot) that Java's detail screen now renders
  all 6 modules ("18 concepts · ~16h") with clean text truncation on long
  titles — no regressions from the wave-1 overflow fix.

### Git
- Pushed to GitHub: yes

## 2026-08-14 (fix: wave-1 content not showing on-device)

### Fixed
- The 13 new subjects (Java, Spring Boot, etc.) still showed "Coming Soon"
  on-device after the wave-1 commit, despite `manifest.json` pointing at
  real module files. Root cause: `pubspec.yaml`'s `assets:` list only
  declared `assets/curriculum/python/` and `assets/curriculum/react/` as
  bundled directories — the 13 new subject folders were never registered,
  so Flutter's asset bundle didn't include them at all.
  `rootBundle.loadString()` threw for every path under those subjects,
  which the existing broad `catch (e)` silently absorbed per-module
  (correct behavior for a genuinely missing file), leaving each path's
  `modules` list empty — exactly the condition the UI already treats as
  "Coming Soon". Fixed by adding all 13 directories to `pubspec.yaml`.
- Found and fixed a second, real bug while verifying the above on an
  emulator: the module-card concept list in `LearningPathDetailScreen`
  (`_ModuleCard`) used a `Wrap` of `Row(mainAxisSize: MainAxisSize.min)`
  items with an unbounded `Text` — fine for short concept titles like
  Python's, but a longer, more descriptive title (e.g. "The main Method:
  How a Java Program Starts and Runs") overflowed past the card edge
  (visible as Flutter's debug `RenderFlex` overflow banner; would have
  silently clipped in release). Fixed by capping each item at
  `maxWidth: 280` via `ConstrainedBox` and wrapping the `Text` in
  `Flexible` with `maxLines: 1` + `TextOverflow.ellipsis`.

### Verification
- Rebuilt debug APK, installed on the running Android emulator
  (API 37, x86_64), and manually verified via adb screenshots + UI-dump
  taps: Learning Paths list shows real concept counts/hours for all 13
  subjects (no "Coming Soon" chip), Java's detail screen renders both
  modules, and the long JVM/bytecode concept title now truncates with an
  ellipsis instead of overflowing.
- flutter analyze: passed (same 4 pre-existing unrelated info-level hints)
- flutter test: passed (17/17)

### Git
- Pushed to GitHub: yes

## 2026-08-14 (wave 1: placeholder subjects get real content)

### Added
- Real curriculum content for all 13 previously-empty learning paths (Java,
  Spring Boot, Node.js, Go, Databases & PostgreSQL, Vector Databases, AI &
  Machine Learning, LLM Engineering, Docker & Containers, Kubernetes, System
  Design, Cloud Architecture & AWS, DevOps) — each now has 2 foundational
  modules (6 concepts, ~230-250 minutes) at the same depth bar as the
  existing Python/React content (multi-section WHY-focused explanations,
  worked examples, misconceptions, hint-bearing exercises, MCQ + explanation
  assessments). This is wave 1 of a multi-wave rollout — each subject's
  first 2 modules only, not the full eventual course.
- Generated via 13 parallel isolated background agents (one per subject, no
  shared file writes), each independently designing its module/concept
  breakdown from a short topic brief since instructions.md only lists these
  subjects by name, not by curriculum detail the way Python/React were
  specified.
- `assets/curriculum/manifest.json` updated for all 13 subjects:
  `moduleFiles` populated, `estimatedHours` set to 5 (consistent with the
  ~1.3x buffer already implicit in Python's/React's manifest estimates vs.
  raw concept-minute sums).

### Verification
- Every one of the 13 agents' output was independently re-validated by the
  orchestrating session (not just trusted from the agent's self-report):
  JSON parses, schema shape (learningObjectives/sections/examples/
  misconceptions/exercises/assessments cardinality), and a grep sweep for
  leftover placeholder/stub tokens — all 26 new files clean.
- Global concept-id uniqueness checked across the entire curriculum (new +
  existing): no collisions.
- Every module file referenced by manifest.json (47 total) confirmed to
  exist and parse — simulates the app's loader end to end.
- flutter analyze: passed (4 pre-existing `info`-level lint hints in
  record_attempt_use_case.dart, unrelated to this change)
- flutter test: passed (17/17)

### Git
- Pushed to GitHub: yes

## 2026-08-14

### Added
- Version bumped to `0.2.0+2` for the second release.
- Completed the seed curriculum set: Python `files_and_data`, `tooling`,
  `web_and_data`, `async_python`; React `js_language_deep_dive`. Generated via
  7 parallel background agents (73 concepts / 355 ids total, validated with a
  Python script mirroring the Dart schema).
- Expanded curriculum breadth: 13 placeholder learning paths added to
  `manifest.json` with empty `moduleFiles` (Java, Spring Boot, Node.js, Go,
  Databases, Vector Databases, AI/ML, LLM Engineering, Docker, Kubernetes,
  System Design, AWS, DevOps) so the Learning Paths screen shows the intended
  breadth immediately; content fills in later without an app update.
- "Coming Soon" empty states for paths/modules with no content yet
  (`learning_paths_screen.dart`, `learning_path_detail_screen.dart`).
- Full gradient + animation pass: `AppGradients` (primary/scaffold/progress),
  app-wide gradient wash painted behind routed content, staggered
  `FadeSlideIn` card entrances, `TweenAnimationBuilder`-driven progress bars,
  custom fade+slide page transitions, `AnimatedSwitcher` cross-fades in
  `AsyncValueView`.
- Atkinson Hyperlegible font bundled as local TTF assets (not `google_fonts`
  — that fetches over the network, which conflicts with the offline-first
  requirement in §26).
- Custom app icon: a hand-drawn graduation-cap mark (pure vector Path/Canvas,
  not an icon-font glyph — those don't render reliably inside `flutter test`'s
  VM runner) on the app's gradient, generated via Flutter golden-file capture
  (`test/_generate_icon.dart`) and applied to Android adaptive icons + iOS
  icon set via `flutter_launcher_icons` (pinned to `0.14.4`; the
  auto-resolved `0.9.3` predates Kotlin DSL `build.gradle.kts` support).

### Fixed
- Curriculum loader must catch `Error`, not just `Exception` — a missing or
  malformed module JSON surfaces as `FlutterError` (extends `Error`) from
  `rootBundle.loadString`, so the per-module try/catch was letting one bad
  file take down the entire learning-path list instead of skipping it.

### Verification
- flutter analyze: passed
- flutter test: passed (incl. golden-file icon generation)
- Live on-device pass on Android confirming redesigned UI + expanded
  curriculum load correctly

### Git
- Commits: `767fe81`, `d5f5aee`, `1ad5f3c`, `04f5ebe`, `ac7a33b`, `f4ca3f5`
- Tag: `v0.2.0` — "Full curriculum, redesign, and app icon"
- Pushed to GitHub: yes

## 2026-08-13

### Added
- Core architecture foundation: app shell, `go_router` routing, central
  theme, Drift/SQLite database layer, repository abstractions, feature-folder
  structure, configuration layer, application-level error handling.
- Python and ReactJS seed curriculum as versioned JSON assets
  (`assets/curriculum/`), loaded and validated into the domain model rather
  than hard-coded into widgets.
- Mastery, review scheduling, and attempt-recording engine: 6-dimension EMA
  mastery model (recall/understanding/application/explanation/coding/
  debugging), interval-doubling spaced-repetition scheduler (deliberately
  simple per §23, not SM-2), `RecordAttemptUseCase`.
- Full vertical slice end to end: Dashboard → Python → Functions → Closures
  → Lesson → Exercise → Assessment → Mastery update → Review scheduled →
  Dashboard reflects it — per §52's first-vertical-slice priority.
- Per-user secure API key storage: replaced `.env` with
  `flutter_secure_storage` (Android Keystore / iOS Keychain-backed). API keys
  differ per installer and must never be bundled into the APK, where they'd
  be trivially extracted by unzipping.

### Fixed
- Exercise/assessment prompts, model answers, and MCQ explanations now
  render as markdown instead of plain text (fenced code and inline code
  spans were showing raw backticks).
- `ListTile` trailing overflow on the module/topic screen — difficulty/time
  metadata moved into `subtitle`, which sizes naturally.
- Stale progress/mastery/review reads after correct answers: Riverpod
  `FutureProviders` were never invalidated after a write, so dashboard/
  progress could show 0% indefinitely. Added a shared `dataRevisionProvider`
  "revision tick" that read-providers watch, bumped by attempt recording.
- Progress screen's rolled-up learning/developing/proficient stat chip
  mislabeled "Learning" — relabeled "In Progress".
- Android release build failure: `flutter_secure_storage` 11.0.0 hardcodes
  `compileSdk 37`, which Google isn't publishing as a plain SDK platform this
  cycle. Pinned the package to `10.3.1` and the app's own `compileSdk` to
  `36`.

### Verification
- flutter analyze: passed
- flutter test: passed
- Verified live on Android emulator/device: full closures lesson loop, plus
  mastery/review state persisting correctly across app restarts (confirmed
  by pulling the on-device SQLite file via `adb exec-out` and inspecting
  with Python's `sqlite3` module).

### Git
- Commits: `c19038b`, `55dadd6`, `6e51557`, `781d9d0`, `c03b6ea`, `0f9d257`,
  `63d15ab`, `af15fcc`
- Tag: `v0.1.0` — "First installable build"
- Pushed to GitHub: yes
