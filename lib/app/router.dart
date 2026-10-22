import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/routes.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/assessment/presentation/screens/module_test_screen.dart';
import '../features/challenges/presentation/screens/challenge_lab_screen.dart';
import '../features/challenges/presentation/screens/challenge_set_screen.dart';
import '../features/coding_challenges/presentation/screens/coding_challenge_list_screen.dart';
import '../features/coding_challenges/presentation/screens/coding_challenge_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/roadmap/presentation/screens/roadmap_screen.dart';
import '../features/study_plan/presentation/screens/study_plan_screen.dart';
import '../features/system_design/presentation/screens/system_design_exercise_screen.dart';
import '../features/system_design/presentation/screens/system_design_list_screen.dart';
import '../features/curriculum/presentation/screens/learning_path_detail_screen.dart';
import '../features/curriculum/presentation/screens/learning_paths_screen.dart';
import '../features/curriculum/presentation/screens/module_detail_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/flashcards/domain/models/flash_card.dart';
import '../features/flashcards/presentation/screens/flash_card_screen.dart';
import '../features/interview/presentation/screens/interview_prep_screen.dart';
import '../features/interview/presentation/screens/interview_session_screen.dart';
import '../features/learning/presentation/screens/lesson_screen.dart';
import '../features/practice/presentation/screens/practice_screen.dart';
import '../features/practice/presentation/screens/practice_session_screen.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import '../features/profile/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/review/presentation/screens/review_screen.dart';
import '../features/review/presentation/screens/review_session_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/skill_check/presentation/screens/skill_check_screen.dart';
import 'app_shell.dart';
import 'navigation.dart';
import 'startup_redirect.dart';

/// Lets code outside the widget tree (a tapped notification callback) push
/// a route without needing a [BuildContext] of its own.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod's [learnerProfileControllerProvider] to go_router's
/// [GoRouter.refreshListenable] — without this, `redirect` only re-runs on
/// navigation events, so the loading->loaded transition on first launch
/// (which happens with no user-driven navigation) would never trigger the
/// initial redirect to onboarding.
class _ProfileRefreshListenable extends ChangeNotifier {
  _ProfileRefreshListenable(Ref ref) {
    ref.listen(learnerProfileControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _ProfileRefreshListenable(ref);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) => startupRedirect(
      profile: ref.read(learnerProfileControllerProvider),
      uri: state.uri,
    ),
    routes: buildAppRoutes(),
  );
});

/// Builds the screen for a route. Tests swap these for lightweight stand-ins
/// so the real route tree and navigation rules can be exercised without a
/// database.
typedef ScreenBuilder = Widget Function(GoRouterState state);

class AppScreens {
  const AppScreens({
    this.onboarding = _onboarding,
    this.flashCard = _flashCard,
    this.settings = _settings,
    this.practice = _practice,
    this.practiceSession = _practiceSession,
    this.review = _review,
    this.reviewSession = _reviewSession,
    this.learningPath = _learningPath,
    this.topic = _topic,
    this.topicTest = _topicTest,
    this.lesson = _lesson,
    this.skillCheck = _skillCheck,
    this.interviewPrep = _interviewPrep,
    this.analytics = _analytics,
    this.challengeLab = _challengeLab,
    this.challengeSet = _challengeSet,
    this.projects = _projects,
    this.projectDetail = _projectDetail,
    this.studyPlan = _studyPlan,
    this.roadmap = _roadmap,
    this.codingChallenges = _codingChallenges,
    this.codingChallenge = _codingChallenge,
    this.systemDesign = _systemDesign,
    this.systemDesignExercise = _systemDesignExercise,
    this.interviewSession = _interviewSession,
    this.dashboard = _dashboard,
    this.learn = _learn,
    this.progress = _progress,
    this.profile = _profile,
    this.shell = _shell,
  });

  final ScreenBuilder onboarding;
  final ScreenBuilder flashCard;
  final ScreenBuilder settings;
  final ScreenBuilder practice;
  final ScreenBuilder practiceSession;
  final ScreenBuilder review;
  final ScreenBuilder reviewSession;
  final ScreenBuilder learningPath;
  final ScreenBuilder topic;
  final ScreenBuilder topicTest;
  final ScreenBuilder lesson;
  final ScreenBuilder skillCheck;
  final ScreenBuilder interviewPrep;
  final ScreenBuilder analytics;
  final ScreenBuilder challengeLab;
  final ScreenBuilder challengeSet;
  final ScreenBuilder projects;
  final ScreenBuilder projectDetail;
  final ScreenBuilder studyPlan;
  final ScreenBuilder roadmap;
  final ScreenBuilder codingChallenges;
  final ScreenBuilder codingChallenge;
  final ScreenBuilder systemDesign;
  final ScreenBuilder systemDesignExercise;
  final ScreenBuilder interviewSession;
  final ScreenBuilder dashboard;
  final ScreenBuilder learn;
  final ScreenBuilder progress;
  final ScreenBuilder profile;
  final Widget Function(StatefulNavigationShell shell) shell;

  static Widget _onboarding(GoRouterState s) => const OnboardingScreen();
  static Widget _flashCard(GoRouterState s) {
    // `extra` is not guaranteed: it is lost on process restore and is
    // absent for deep links, so never cast it blindly.
    final card = FlashCard.tryParse(s.extra);
    return card == null
        ? const FlashCardUnavailableScreen()
        : FlashCardScreen(card: card);
  }

  static Widget _settings(GoRouterState s) => const SettingsScreen();
  static Widget _practice(GoRouterState s) => const PracticeScreen();
  static Widget _practiceSession(GoRouterState s) =>
      PracticeSessionScreen(conceptId: s.pathParameters['conceptId']!);
  static Widget _review(GoRouterState s) => const ReviewScreen();
  static Widget _reviewSession(GoRouterState s) =>
      ReviewSessionScreen(conceptId: s.pathParameters['conceptId']!);
  static Widget _learningPath(GoRouterState s) =>
      LearningPathDetailScreen(pathId: s.pathParameters['pathId']!);
  static Widget _topic(GoRouterState s) => ModuleDetailScreen(
    pathId: s.pathParameters['pathId']!,
    moduleId: s.pathParameters['moduleId']!,
  );
  static Widget _topicTest(GoRouterState s) => ModuleTestScreen(
    pathId: s.pathParameters['pathId']!,
    moduleId: s.pathParameters['moduleId']!,
  );
  static Widget _lesson(GoRouterState s) => LessonScreen(
    pathId: s.pathParameters['pathId']!,
    moduleId: s.pathParameters['moduleId']!,
    conceptId: s.pathParameters['conceptId']!,
  );
  static Widget _skillCheck(GoRouterState s) =>
      SkillCheckScreen(pathId: s.pathParameters['pathId']!);
  static Widget _interviewPrep(GoRouterState s) => const InterviewPrepScreen();
  static Widget _interviewSession(GoRouterState s) =>
      InterviewSessionScreen(pathId: s.pathParameters['pathId']!);
  static Widget _analytics(GoRouterState s) => const AnalyticsScreen();
  static Widget _challengeLab(GoRouterState s) => const ChallengeLabScreen();
  static Widget _challengeSet(GoRouterState s) => ChallengeSetScreen(
    pathId: s.pathParameters['pathId']!,
    kindName: s.pathParameters['kind']!,
  );
  static Widget _projects(GoRouterState s) => const ProjectsScreen();
  static Widget _projectDetail(GoRouterState s) =>
      ProjectDetailScreen(projectId: s.pathParameters['projectId']!);
  static Widget _studyPlan(GoRouterState s) => const StudyPlanScreen();
  static Widget _roadmap(GoRouterState s) => const RoadmapScreen();
  static Widget _systemDesign(GoRouterState s) =>
      const SystemDesignListScreen();
  static Widget _systemDesignExercise(GoRouterState s) =>
      SystemDesignExerciseScreen(exerciseId: s.pathParameters['exerciseId']!);
  static Widget _codingChallenges(GoRouterState s) =>
      const CodingChallengeListScreen();
  static Widget _codingChallenge(GoRouterState s) =>
      CodingChallengeScreen(challengeId: s.pathParameters['challengeId']!);
  static Widget _dashboard(GoRouterState s) => const DashboardScreen();
  static Widget _learn(GoRouterState s) => const LearningPathsScreen();
  static Widget _progress(GoRouterState s) => const ProgressScreen();
  static Widget _profile(GoRouterState s) => const ProfileScreen();
  static Widget _shell(StatefulNavigationShell shell) =>
      AppShell(navigationShell: shell);
}

/// The route tree.
///
/// Only the four tab roots live inside the shell. Every other screen is a
/// top-level route on the root navigator, so `push` stacks it over whatever
/// the learner was looking at (any tab, or another pushed screen) and back
/// returns exactly there. URLs are unchanged, so deep links keep working;
/// a deep link opened cold builds the URL's parent pages underneath, and
/// [_BackFallback] sends back from the bottom-most one to [Routes.dashboard]
/// instead of exiting the app.
List<RouteBase> buildAppRoutes({AppScreens screens = const AppScreens()}) {
  Widget page(ScreenBuilder b, GoRouterState s) => _BackFallback(child: b(s));

  return [
    GoRoute(
      path: Routes.launch,
      // Paints nothing: the app-wide background from TeacherApp shows
      // through, which matches the native splash colour.
      builder: (context, state) => const SizedBox.expand(),
    ),
    GoRoute(
      path: Routes.onboarding,
      builder: (context, state) => screens.onboarding(state),
    ),
    GoRoute(
      path: Routes.flashCard,
      builder: (context, state) => screens.flashCard(state),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => page(screens.settings, state),
    ),
    GoRoute(
      path: Routes.legacyProfileSettings,
      redirect: (context, state) => Routes.settings,
    ),
    GoRoute(
      path: Routes.practice,
      builder: (context, state) => page(screens.practice, state),
      routes: [
        GoRoute(
          path: ':conceptId',
          builder: (context, state) => page(screens.practiceSession, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.challengeLab,
      builder: (context, state) => page(screens.challengeLab, state),
      routes: [
        GoRoute(
          path: ':pathId/:kind',
          builder: (context, state) => page(screens.challengeSet, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.systemDesign,
      builder: (context, state) => page(screens.systemDesign, state),
      routes: [
        GoRoute(
          path: ':exerciseId',
          builder: (context, state) =>
              page(screens.systemDesignExercise, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.codingChallenges,
      builder: (context, state) => page(screens.codingChallenges, state),
      routes: [
        GoRoute(
          path: ':challengeId',
          builder: (context, state) => page(screens.codingChallenge, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.studyPlan,
      builder: (context, state) => page(screens.studyPlan, state),
    ),
    GoRoute(
      path: Routes.roadmap,
      builder: (context, state) => page(screens.roadmap, state),
    ),
    GoRoute(
      path: Routes.projects,
      builder: (context, state) => page(screens.projects, state),
      routes: [
        GoRoute(
          path: ':projectId',
          builder: (context, state) => page(screens.projectDetail, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.analytics,
      builder: (context, state) => page(screens.analytics, state),
    ),
    GoRoute(
      path: Routes.interviewPrep,
      builder: (context, state) => page(screens.interviewPrep, state),
      routes: [
        GoRoute(
          path: ':pathId',
          builder: (context, state) => page(screens.interviewSession, state),
        ),
      ],
    ),
    GoRoute(
      path: Routes.review,
      builder: (context, state) => page(screens.review, state),
      routes: [
        GoRoute(
          path: ':conceptId',
          builder: (context, state) => page(screens.reviewSession, state),
        ),
      ],
    ),
    GoRoute(
      path: '${Routes.learn}/:pathId',
      builder: (context, state) => page(screens.learningPath, state),
      routes: [
        // Static segment before the `:moduleId` wildcard (declaration order).
        GoRoute(
          path: 'skill-check',
          builder: (context, state) => page(screens.skillCheck, state),
        ),
        GoRoute(
          path: ':moduleId',
          builder: (context, state) => page(screens.topic, state),
          routes: [
            // Static 'test' must come before the `:conceptId` wildcard:
            // go_router tries siblings in declaration order.
            GoRoute(
              path: 'test',
              builder: (context, state) => page(screens.topicTest, state),
            ),
            GoRoute(
              path: ':conceptId',
              builder: (context, state) => page(screens.lesson, state),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          screens.shell(navigationShell),
      branches: [
        for (final (path, builder) in [
          (Routes.dashboard, screens.dashboard),
          (Routes.learn, screens.learn),
          (Routes.progress, screens.progress),
          (Routes.profile, screens.profile),
        ])
          StatefulShellBranch(
            routes: [
              GoRoute(path: path, builder: (context, state) => builder(state)),
            ],
          ),
      ],
    ),
  ];
}

/// Makes system back on the bottom-most pushed screen (only possible after
/// a cold-start deep link) go to the Dashboard instead of closing the app.
/// When there is a screen underneath it does nothing: normal pop.
class _BackFallback extends StatelessWidget {
  const _BackFallback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goBack();
      },
      child: child,
    );
  }
}
