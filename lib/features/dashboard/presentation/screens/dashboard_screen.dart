import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/path_progress_summary.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Greeting(),
            const SizedBox(height: 24),
            _ContinueLearningCard(),
            const SizedBox(height: 24),
            _LearningProgressSection(),
            const SizedBox(height: 24),
            _ReviewQueueCard(),
            const SizedBox(height: 24),
            _RecommendedNextStepCard(),
            const SizedBox(height: 24),
            _RecentActivitySection(),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
        Text('Ready to learn?', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _ContinueLearningCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptValue = ref.watch(continueLearningProvider);
    final concept = conceptValue.valueOrNull;

    if (conceptValue.isLoading) {
      return const SizedBox.shrink();
    }
    if (concept == null) {
      return _EmptyContinueCard();
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(
          Routes.lesson(concept.learningPathId, concept.moduleId, concept.id),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Continue Learning',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                concept.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                concept.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
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
        ),
      ),
    );
  }
}

class _EmptyContinueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's learn Python.",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Pick a learning path to get started.'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => context.go(Routes.learn),
                child: const Text('Browse Learning Paths'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningProgressSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(pathProgressSummariesProvider);
    final summaries =
        summariesValue.valueOrNull ?? const <PathProgressSummary>[];
    if (summaries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Progress',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueValue = ref.watch(dueSchedulesProvider);
    final count = dueValue.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Card(
      child: ListTile(
        onTap: () => context.go(Routes.review),
        leading: const Icon(Icons.replay_circle_filled_outlined),
        title: Text('$count concept${count == 1 ? '' : 's'} due for review'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _RecommendedNextStepCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationValue = ref.watch(dashboardRecommendationProvider);
    final recommendation = recommendationValue.valueOrNull;
    if (recommendation == null) return const SizedBox.shrink();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedValue = ref.watch(recentlyCompletedProvider);
    final completed = completedValue.valueOrNull ?? const [];
    if (completed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
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
