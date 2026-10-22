import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/models/study_plan.dart';
import '../providers/study_plan_providers.dart';

IconData planStepIcon(PlanStepKind kind) => switch (kind) {
  PlanStepKind.review => Icons.replay_outlined,
  PlanStepKind.strengthen => Icons.fitness_center_outlined,
  PlanStepKind.topicTest => Icons.fact_check_outlined,
  PlanStepKind.learn => Icons.menu_book_outlined,
  PlanStepKind.project => Icons.construction_outlined,
  PlanStepKind.challenge => Icons.bug_report_outlined,
  PlanStepKind.interview => Icons.record_voice_over_outlined,
  PlanStepKind.systemDesign => Icons.account_tree_outlined,
  PlanStepKind.startCourse => Icons.school_outlined,
};

/// Opens the screen a plan step points at.
void openPlanStep(BuildContext context, PlanStep step) {
  switch (step.kind) {
    case PlanStepKind.review:
      context.openReview();
    case PlanStepKind.strengthen:
      context.openPracticeSession(step.conceptId!);
    case PlanStepKind.topicTest:
      context.openTopicTest(step.pathId!, step.moduleId!);
    case PlanStepKind.learn:
      context.openLesson(step.pathId!, step.moduleId!, step.conceptId!);
    case PlanStepKind.project:
      context.openProject(step.projectId!);
    case PlanStepKind.challenge:
      context.openChallengeSet(step.pathId!, 'debugging');
    case PlanStepKind.interview:
      context.openInterviewSession(step.pathId!);
    case PlanStepKind.systemDesign:
      context.openSystemDesignExercise(step.exerciseId!);
    case PlanStepKind.startCourse:
      context.switchToTab(Routes.learn);
  }
}

/// A personal, ordered plan built from reviews, weak spots, progress and
/// applied work. Recomputed whenever progress changes.
class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(studyPlanProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Your study plan')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(studyPlanProvider),
          skeleton: () => const SkeletonCardList(),
          data: (plan) {
            if (plan.steps.isEmpty) {
              return const EmptyState(
                message:
                    "You're all caught up. Come back after your next "
                    'lesson for new suggestions.',
                icon: Icons.check_circle_outline,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'About ${plan.totalMinutes} min · built from your reviews, '
                  'weak spots and progress',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (plan.careerGoal != null &&
                    plan.careerGoal!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Goal: ${plan.careerGoal}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
                const SizedBox(height: 12),
                for (final (i, step) in plan.steps.indexed)
                  GradientCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      key: ValueKey('plan-step-$i'),
                      onTap: () => openPlanStep(context, step),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: Icon(planStepIcon(step.kind)),
                      ),
                      title: Text('${i + 1}. ${step.title}'),
                      subtitle: Text('${step.reason}\n~${step.minutes} min'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
