import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../assessment/presentation/providers/assessment_providers.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../data/app_open_repository_impl.dart';
import '../../data/learner_profile_repository_impl.dart';
import '../../domain/app_open_repository.dart';
import '../../domain/learner_profile_repository.dart';
import '../../domain/models/learner_profile.dart';
import '../../domain/models/learner_stats.dart';
import '../../domain/profile_stats_service.dart';

final learnerProfileRepositoryProvider = Provider<LearnerProfileRepository>((
  ref,
) {
  return LearnerProfileRepositoryImpl(ref.watch(appDatabaseProvider));
});

class LearnerProfileController extends AsyncNotifier<LearnerProfile> {
  @override
  Future<LearnerProfile> build() {
    return ref.watch(learnerProfileRepositoryProvider).getProfile();
  }

  Future<void> completeOnboarding({
    required String name,
    String? careerGoal,
  }) async {
    await ref
        .read(learnerProfileRepositoryProvider)
        .completeOnboarding(name: name, careerGoal: careerGoal);
    state = AsyncData(
      LearnerProfile(
        name: name,
        careerGoal: careerGoal,
        hasCompletedOnboarding: true,
      ),
    );
  }

  Future<void> setName(String name) async {
    await ref.read(learnerProfileRepositoryProvider).setName(name);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        LearnerProfile(
          name: name,
          careerGoal: current.careerGoal,
          hasCompletedOnboarding: current.hasCompletedOnboarding,
        ),
      );
    }
  }

  Future<void> setCareerGoal(String? careerGoal) async {
    await ref.read(learnerProfileRepositoryProvider).setCareerGoal(careerGoal);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        LearnerProfile(
          name: current.name,
          careerGoal: careerGoal,
          hasCompletedOnboarding: current.hasCompletedOnboarding,
        ),
      );
    }
  }
}

final learnerProfileControllerProvider =
    AsyncNotifierProvider<LearnerProfileController, LearnerProfile>(
      LearnerProfileController.new,
    );

final appOpenRepositoryProvider = Provider<AppOpenRepository>((ref) {
  return AppOpenRepositoryImpl(ref.watch(appDatabaseProvider));
});

final appOpenDayCountProvider = FutureProvider<int>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(appOpenRepositoryProvider).getOpenDayCount();
});

/// Records today's app-open exactly once per calendar day and bumps
/// [dataRevisionProvider] so the XP total refreshes — watched once at
/// startup from `TeacherApp`, mirroring `flashcardStartupProvider`.
final appOpenXpAwardProvider = FutureProvider<void>((ref) async {
  final isNewDay = await ref.read(appOpenRepositoryProvider).recordOpenToday();
  if (isNewDay) ref.read(dataRevisionProvider.notifier).bump();
});

final learnerStatsProvider = FutureProvider<LearnerStats>((ref) async {
  final paths = await ref.watch(learningPathsProvider.future);
  final allProgress = await ref.watch(allStudentProgressProvider.future);
  final allAttempts = await ref.watch(allAttemptsProvider.future);
  final passedModuleTestCount = await ref.watch(
    allPassedModuleTestCountProvider.future,
  );
  final appOpenDays = await ref.watch(appOpenDayCountProvider.future);
  return ProfileStatsService().compute(
    paths: paths,
    allProgress: allProgress,
    allAttempts: allAttempts,
    passedModuleTestCount: passedModuleTestCount,
    appOpenDays: appOpenDays,
  );
});
