import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/routes.dart';
import '../features/assessment/presentation/screens/module_test_screen.dart';
import '../features/curriculum/presentation/screens/learning_path_detail_screen.dart';
import '../features/curriculum/presentation/screens/learning_paths_screen.dart';
import '../features/curriculum/presentation/screens/module_detail_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/flashcards/domain/models/flash_card.dart';
import '../features/flashcards/presentation/screens/flash_card_screen.dart';
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
import 'app_shell.dart';

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
    redirect: (context, state) {
      final profile = ref.read(learnerProfileControllerProvider).valueOrNull;
      if (profile == null) return null;
      final onOnboarding = state.matchedLocation == Routes.onboarding;
      if (!profile.hasCompletedOnboarding && !onOnboarding) {
        return Routes.onboarding;
      }
      if (profile.hasCompletedOnboarding && onOnboarding) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.flashCard,
        builder: (context, state) =>
            FlashCardScreen(card: state.extra as FlashCard),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.learn,
                builder: (context, state) => const LearningPathsScreen(),
                routes: [
                  GoRoute(
                    path: ':pathId',
                    builder: (context, state) => LearningPathDetailScreen(
                      pathId: state.pathParameters['pathId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: ':moduleId',
                        builder: (context, state) => ModuleDetailScreen(
                          pathId: state.pathParameters['pathId']!,
                          moduleId: state.pathParameters['moduleId']!,
                        ),
                        routes: [
                          // Static routes must be declared before the
                          // sibling `:conceptId` wildcard — go_router tries
                          // sibling routes in declaration order, so a
                          // dynamic param declared first would otherwise
                          // swallow this literal segment (e.g. matching
                          // '.../test' as conceptId == 'test').
                          GoRoute(
                            path: 'test',
                            builder: (context, state) => ModuleTestScreen(
                              pathId: state.pathParameters['pathId']!,
                              moduleId: state.pathParameters['moduleId']!,
                            ),
                          ),
                          GoRoute(
                            path: ':conceptId',
                            builder: (context, state) => LessonScreen(
                              pathId: state.pathParameters['pathId']!,
                              moduleId: state.pathParameters['moduleId']!,
                              conceptId: state.pathParameters['conceptId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.practice,
                builder: (context, state) => const PracticeScreen(),
                routes: [
                  GoRoute(
                    path: ':conceptId',
                    builder: (context, state) => PracticeSessionScreen(
                      conceptId: state.pathParameters['conceptId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.review,
                builder: (context, state) => const ReviewScreen(),
                routes: [
                  GoRoute(
                    path: ':conceptId',
                    builder: (context, state) => ReviewSessionScreen(
                      conceptId: state.pathParameters['conceptId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
