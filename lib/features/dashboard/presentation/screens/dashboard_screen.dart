import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../../assessment/presentation/providers/pending_tests_provider.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/domain/models/path_progress_summary.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../domain/models/continue_learning_state.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sections = [
      _Greeting(),
      _ContinueLearningCard(),
      _LearningProgressSection(),
      _ReviewQueueCard(),
      _PracticeQueueCard(),
      _PendingTestsCard(),
      _RecommendedNextStepCard(),
      _RecentActivitySection(),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) =>
              FadeSlideIn(index: index, child: sections[index]),
        ),
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(learnerProfileControllerProvider).valueOrNull;
    final name = profile?.name ?? '';

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Hi there 👋' : 'Hi $name 👋',
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          'Ready to continue learning?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends ConsumerWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateValue = ref.watch(continueLearningProvider);
    final state = stateValue.valueOrNull;

    if (stateValue.isLoading) {
      return const SizedBox.shrink();
    }

    return switch (state) {
      null || ContinueLearningEmpty() => const _EmptyContinueCard(),
      ContinueLearningConcept(concept: final concept) => _HeroGradientCard(
        onTap: () => context.go(
          Routes.lesson(concept.learningPathId, concept.moduleId, concept.id),
        ),
        children: [
          const Text(
            'Continue Learning',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            concept.title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            concept.description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.go(
                Routes.lesson(
                  concept.learningPathId,
                  concept.moduleId,
                  concept.id,
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
      ContinueLearningPathCompleted(pathTitle: final title) =>
        _PathCompletedCard(pathTitle: title),
    };
  }
}

class _EmptyContinueCard extends StatelessWidget {
  const _EmptyContinueCard();

  @override
  Widget build(BuildContext context) {
    return _HeroGradientCard(
      onTap: () => context.go(Routes.learn),
      children: [
        const Text(
          "Let's start learning.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pick a learning path to get started.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.go(Routes.learn),
            child: const Text('Browse Learning Paths'),
          ),
        ),
      ],
    );
  }
}

class _PathCompletedCard extends StatelessWidget {
  const _PathCompletedCard({required this.pathTitle});

  final String pathTitle;

  @override
  Widget build(BuildContext context) {
    return _HeroGradientCard(
      onTap: () => context.go(Routes.learn),
      children: [
        Text(
          "You've completed $pathTitle! 🎉",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Great work. Ready for another course?',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.go(Routes.learn),
            child: const Text('Browse Learning Paths'),
          ),
        ),
      ],
    );
  }
}

/// Shared visual treatment for the dashboard's single "hero" moment — a
/// subtle brand gradient, reserved for exactly one card per screen so it
/// reads as a highlight rather than visual noise. See instructions.md
/// section 7 ("keep subtle gradients").
class _HeroGradientCard extends StatelessWidget {
  const _HeroGradientCard({required this.children, this.onTap});

  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary(colorScheme),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _LearningProgressSection extends ConsumerWidget {
  const _LearningProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(startedPathProgressSummariesProvider);
    final summaries =
        summariesValue.valueOrNull ?? const <PathProgressSummary>[];
    if (summaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Learning Progress'),
        const SizedBox(height: 12),
        Card(
          elevation: AppElevation.prominent,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < summaries.length; i++) ...[
                  LabeledProgressBar(
                    label: summaries[i].title,
                    progress: summaries[i].overallPercent,
                  ),
                  if (i != summaries.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewQueueCard extends ConsumerWidget {
  const _ReviewQueueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueValue = ref.watch(dueSchedulesProvider);
    final count = dueValue.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Card(
      elevation: AppElevation.flat,
      child: ListTile(
        onTap: () => context.go(Routes.review),
        leading: const Icon(Icons.replay_circle_filled_outlined),
        title: Text('$count concept${count == 1 ? '' : 's'} due for review'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PracticeQueueCard extends ConsumerWidget {
  const _PracticeQueueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueValue = ref.watch(practiceQueueProvider);
    final count = queueValue.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Card(
      elevation: AppElevation.flat,
      child: ListTile(
        onTap: () => context.go(Routes.practice),
        leading: const Icon(Icons.edit_note_outlined),
        title: Text('$count concept${count == 1 ? '' : 's'} ready to practice'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PendingTestsCard extends ConsumerWidget {
  const _PendingTestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingValue = ref.watch(pendingTestsProvider);
    final pending = pendingValue.valueOrNull ?? const [];
    if (pending.isEmpty) return const SizedBox.shrink();

    final count = pending.length;
    final first = pending.first;

    return Card(
      elevation: AppElevation.flat,
      child: ListTile(
        onTap: () => context.go(
          Routes.lesson(first.learningPathId, first.moduleId, first.id),
        ),
        leading: const Icon(Icons.quiz_outlined),
        title: Text('$count test${count == 1 ? '' : 's'} pending'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _RecommendedNextStepCard extends ConsumerWidget {
  const _RecommendedNextStepCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationValue = ref.watch(dashboardRecommendationProvider);
    final recommendation = recommendationValue.valueOrNull;
    if (recommendation == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: AppGradients.primary(colorScheme),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => context.go(
                  Routes.lesson(
                    recommendation.concept.learningPathId,
                    recommendation.concept.moduleId,
                    recommendation.concept.id,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Next',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${recommendation.learningPathTitle} → ${recommendation.moduleTitle} → '
                        '${recommendation.concept.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recommendation.reason,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedValue = ref.watch(recentlyCompletedProvider);
    final completed = completedValue.valueOrNull ?? const [];
    if (completed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Recent Activity'),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final progress in completed)
                _RecentActivityTile(
                  conceptId: progress.conceptId,
                  completedAt: progress.completedAt!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivityTile extends ConsumerWidget {
  const _RecentActivityTile({
    required this.conceptId,
    required this.completedAt,
  });

  final String conceptId;
  final DateTime completedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptValue = ref.watch(conceptProvider(conceptId));
    final title = conceptValue.valueOrNull?.title ?? conceptId;

    return ListTile(
      leading: const Icon(Icons.task_alt, size: 20),
      title: Text(title),
      subtitle: Text(_relativeTime(completedAt)),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
