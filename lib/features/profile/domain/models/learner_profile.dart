import 'package:equatable/equatable.dart';

/// The learner's own identity — name and an optional career goal captured
/// once during onboarding. See instructions.md section 45.
class LearnerProfile extends Equatable {
  const LearnerProfile({
    required this.name,
    required this.careerGoal,
    required this.hasCompletedOnboarding,
  });

  final String name;
  final String? careerGoal;
  final bool hasCompletedOnboarding;

  static const empty = LearnerProfile(
    name: '',
    careerGoal: null,
    hasCompletedOnboarding: false,
  );

  @override
  List<Object?> get props => [name, careerGoal, hasCompletedOnboarding];
}
