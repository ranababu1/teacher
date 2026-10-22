import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/routes.dart';

/// The app's navigation rules in one place (see docs/changelog.md, 0.17.0):
///
/// - Tabs are roots: switching tabs uses `go` / `goBranch` only.
/// - Drill-downs, shortcuts and detours push, so back retraces exactly the
///   screens the learner visited (1 > 2 > 3, back 3 > 2 > 1).
/// - Finishing something pops back to where the learner came from.
/// - `go` elsewhere is reserved for resets (onboarding finished, flash-card
///   fallback, cold-start deep links with nothing underneath).
///
/// Screens call these instead of `context.go`/`push` directly, so the
/// rules cannot drift screen by screen.
extension AppNavigation on BuildContext {
  GoRouter get _router => GoRouter.of(this);

  void openLearningPath(String pathId) =>
      _router.push(Routes.learningPath(pathId));

  void openSkillCheck(String pathId) => _router.push(Routes.skillCheck(pathId));

  void openTopic(String pathId, String moduleId) =>
      _router.push(Routes.module(pathId, moduleId));

  void openLesson(String pathId, String moduleId, String conceptId) =>
      _router.push(Routes.lesson(pathId, moduleId, conceptId));

  void openTopicTest(String pathId, String moduleId) =>
      _router.push(Routes.moduleTest(pathId, moduleId));

  void openPractice() => _router.push(Routes.practice);

  void openPracticeSession(String conceptId) =>
      _router.push(Routes.practiceSession(conceptId));

  void openReview() => _router.push(Routes.review);

  void openReviewSession(String conceptId) =>
      _router.push(Routes.reviewSession(conceptId));

  void openInterviewPrep() => _router.push(Routes.interviewPrep);

  void openInterviewSession(String pathId) =>
      _router.push(Routes.interviewSession(pathId));

  void openAnalytics() => _router.push(Routes.analytics);

  void openChallengeLab() => _router.push(Routes.challengeLab);

  void openChallengeSet(String pathId, String kind) =>
      _router.push(Routes.challengeSet(pathId, kind));

  void openSettings() => _router.push(Routes.settings);

  /// Switches to a bottom-bar tab (a root, not a drill-down).
  void switchToTab(String tabLocation) => _router.go(tabLocation);

  /// Back / close / "Done": returns to the previous screen. Only when there
  /// is nothing underneath (cold-start deep link) does it go to
  /// [fallbackLocation] instead of leaving the learner stranded.
  void goBack({String fallbackLocation = Routes.dashboard}) {
    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(fallbackLocation);
    }
  }

  /// From a topic page: swap it for the next topic so finished topics do
  /// not pile up in the back stack.
  void replaceWithNextTopic(String pathId, String nextModuleId) =>
      _router.pushReplacement(Routes.module(pathId, nextModuleId));

  /// From a passed topic test: close the test, then swap the topic it was
  /// opened from for the next topic. Back from the next topic therefore
  /// returns to the learning path, not to finished pages.
  void continueFromTestToNextTopic(String pathId, String nextModuleId) {
    final router = _router;
    final next = Routes.module(pathId, nextModuleId);
    if (!router.canPop()) {
      router.go(next);
      return;
    }
    router.pop();
    if (router.canPop()) {
      router.pushReplacement(next);
    } else {
      router.push(next);
    }
  }
}
