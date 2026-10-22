import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_teacher/domain/models/study_coaching.dart';
import '../../../ai_teacher/presentation/providers/teach_providers.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../challenges/domain/challenge_service.dart';
import '../../../challenges/presentation/providers/challenge_providers.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../dashboard/domain/models/continue_learning_state.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../../system_design/presentation/providers/system_design_providers.dart';
import '../../domain/coach_study_plan_use_case.dart';
import '../../domain/models/study_plan.dart';
import '../../domain/study_plan_service.dart';

final studyPlanInputsProvider = FutureProvider<StudyPlanInputs>((ref) async {
  final paths = await ref.watch(learningPathsProvider.future);
  final startedIds = await ref.watch(startedLearningPathIdsProvider.future);
  final started = paths.where((p) => startedIds.contains(p.id)).toList();
  final progress = await ref.watch(allStudentProgressProvider.future);
  final passed = {
    for (final p in started)
      p.id: await ref.watch(passedModuleIdsProvider(p.id).future),
  };
  final due = await ref.watch(dueForReviewProvider.future);
  final analytics = await ref.watch(learningAnalyticsProvider.future);
  final projects = await ref.watch(projectOverviewsProvider.future);
  final cont = await ref.watch(continueLearningProvider.future);
  final next = cont is ContinueLearningConcept
      ? cont.concept
      : (await ref.watch(dashboardRecommendationProvider.future))?.concept;
  final profile = await ref.watch(learnerProfileControllerProvider.future);
  final challenges = ref.read(challengeServiceProvider);
  final design = await ref.watch(systemDesignListProvider.future);
  return StudyPlanInputs(
    startedPaths: started,
    completedConceptIds: {
      for (final p in progress)
        if (p.isCompleted) p.conceptId,
    },
    passedModuleIdsByPath: passed,
    dueReviews: due,
    weakConcepts: analytics.weakConcepts
        .where((w) => startedIds.contains(w.learningPathId))
        .toList(),
    projects: projects,
    debuggingCountByPath: {
      for (final p in started)
        p.id: challenges.counts(p)[ChallengeKind.debugging] ?? 0,
    },
    systemDesign: design,
    nextConcept: next,
    careerGoal: profile.careerGoal,
  );
});

final studyPlanProvider = FutureProvider<StudyPlan>((ref) async {
  final inputs = await ref.watch(studyPlanInputsProvider.future);
  return StudyPlanService().build(inputs);
});

final coachStudyPlanUseCaseProvider = Provider<CoachStudyPlanUseCase>(
  (ref) => CoachStudyPlanUseCase(aiProvider: ref.watch(aiProviderProvider)),
);

/// AI coaching for the current plan. Starts empty; only calls the AI when
/// the learner asks, since it costs a request on their own API key.
class StudyCoachController
    extends AutoDisposeAsyncNotifier<StudyCoachingAdvice?> {
  @override
  Future<StudyCoachingAdvice?> build() async => null;

  Future<void> request() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final inputs = await ref.read(studyPlanInputsProvider.future);
      final plan = await ref.read(studyPlanProvider.future);
      return ref.read(coachStudyPlanUseCaseProvider)(
        plan: plan,
        inputs: inputs,
      );
    });
  }
}

final studyCoachControllerProvider =
    AsyncNotifierProvider.autoDispose<
      StudyCoachController,
      StudyCoachingAdvice?
    >(StudyCoachController.new);
