import 'models/learner_profile.dart';

abstract class LearnerProfileRepository {
  Future<LearnerProfile> getProfile();

  /// Single combined write for the onboarding screen — sets name, career
  /// goal, and marks onboarding done in one call.
  Future<void> completeOnboarding({required String name, String? careerGoal});

  Future<void> setName(String name);

  Future<void> setCareerGoal(String? careerGoal);
}
