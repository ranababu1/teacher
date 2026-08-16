import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/learner_profile_repository_impl.dart';
import '../../domain/learner_profile_repository.dart';
import '../../domain/models/learner_profile.dart';

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
