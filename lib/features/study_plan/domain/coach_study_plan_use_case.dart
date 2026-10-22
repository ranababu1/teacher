import '../../ai_teacher/domain/ai_provider.dart';
import '../../ai_teacher/domain/models/study_coaching.dart';
import 'models/study_plan.dart';
import 'study_plan_service.dart';

/// Asks the AI coach to explain and sharpen the app's own study plan.
/// Plain Dart: builds a compact learner summary from [StudyPlanInputs]
/// (no raw history leaves the device, only counts, titles and accuracy).
class CoachStudyPlanUseCase {
  CoachStudyPlanUseCase({required this.aiProvider});

  final AIProvider aiProvider;

  Future<StudyCoachingAdvice> call({
    required StudyPlan plan,
    required StudyPlanInputs inputs,
  }) {
    return aiProvider.coachStudyPlan(buildRequest(plan: plan, inputs: inputs));
  }

  static StudyCoachingRequest buildRequest({
    required StudyPlan plan,
    required StudyPlanInputs inputs,
  }) {
    final lines = <String>[];
    if (inputs.startedPaths.isEmpty) {
      lines.add('Has not started any course yet.');
    } else {
      lines.add(
        'Courses: ${inputs.startedPaths.map((p) {
          final passed = inputs.passedModuleIdsByPath[p.id]?.length ?? 0;
          return '${p.title} ($passed of ${p.modules.length} topics passed)';
        }).join('; ')}.',
      );
    }
    lines.add('Concepts due for review: ${inputs.dueReviews.length}.');
    if (inputs.weakConcepts.isNotEmpty) {
      lines.add(
        'Weakest concepts: ${inputs.weakConcepts.take(5).map((w) => '${w.title} (${(w.accuracy * 100).round()}% over ${w.attempts} attempts)').join('; ')}.',
      );
    }
    final activeProjects = inputs.projects
        .where((o) => o.isStarted && !o.isComplete)
        .map((o) => '${o.project.title} (${o.completedCount}/${o.totalCount})');
    if (activeProjects.isNotEmpty) {
      lines.add('Projects in progress: ${activeProjects.join('; ')}.');
    }
    return StudyCoachingRequest(
      learnerSummary: lines.join('\n'),
      planSteps: [for (final s in plan.steps) '${s.title}: ${s.reason}'],
      careerGoal: plan.careerGoal,
    );
  }
}
