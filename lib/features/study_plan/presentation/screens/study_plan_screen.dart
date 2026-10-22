import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
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
  PlanStepKind.longChallenge => Icons.terminal_outlined,
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
    case PlanStepKind.longChallenge:
      context.openCodingChallenge(step.challengeId!);
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
            final tips =
                ref.watch(studyCoachControllerProvider).valueOrNull?.stepTips ??
                const <String>[];
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
                      subtitle: Text(
                        '${step.reason}\n~${step.minutes} min'
                        '${i < tips.length ? '\nCoach: ${tips[i]}' : ''}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                const SizedBox(height: 8),
                const _CoachCard(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Optional AI coaching on the plan, fetched only when asked for.
class _CoachCard extends ConsumerWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final value = ref.watch(studyCoachControllerProvider);
    void ask() => ref.read(studyCoachControllerProvider.notifier).request();

    final Widget body;
    if (value.isLoading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (value.hasError) {
      final error = value.error;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error is AppException
                ? error.userMessage
                : "The AI coach couldn't answer right now.",
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: ask, child: const Text('Try Again')),
        ],
      );
    } else if (value.valueOrNull case final advice?) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(advice.summary),
          const SizedBox(height: 8),
          Text('This week', style: theme.textTheme.titleSmall),
          Text(advice.weeklyFocus),
          const SizedBox(height: 4),
          Text(
            'Tips are shown under each step above.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: ask, child: const Text('Ask Again')),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get a short read on where you stand, a focus for the week and '
            'a tip for each step. Uses your AI provider and API key from '
            'Settings; only counts, titles and accuracy are sent.',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: ask,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Ask the AI Coach'),
          ),
        ],
      );
    }
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('AI coach', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }
}
