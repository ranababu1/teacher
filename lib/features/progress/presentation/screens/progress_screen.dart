import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../assessment/domain/models/learning_stats.dart';
import '../../../assessment/presentation/providers/learning_stats_provider.dart';
import '../../domain/models/path_progress_summary.dart';
import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(startedPathProgressSummariesProvider);
    final statsValue = ref.watch(learningStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: AsyncValueView(
          value: summariesValue,
          onRetry: () => ref.invalidate(startedPathProgressSummariesProvider),
          skeleton: () => const SkeletonCardList(itemCount: 3),
          data: (summaries) => summaries.isEmpty
              ? const EmptyState(
                  message: 'Start a learning path to see your progress here.',
                  icon: Icons.insights_outlined,
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionLabel('Overall Learning Progress'),
                    const SizedBox(height: 16),
                    for (final summary in summaries) ...[
                      _PathProgressCard(summary: summary),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    const SectionLabel('Performance'),
                    const SizedBox(height: 12),
                    statsValue.when(
                      data: (stats) => _StatsGrid(stats: stats),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PathProgressCard extends StatelessWidget {
  const _PathProgressCard({required this.summary});

  final PathProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: AppElevation.prominent,
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledProgressBar(
              label: summary.title,
              progress: summary.overallPercent,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _StatChip(
                  label: 'Mastered',
                  value: summary.masteredCount,
                  color: theme.colorScheme.primary,
                ),
                _StatChip(
                  label: 'In Progress',
                  value: summary.inProgressCount,
                  color: theme.colorScheme.tertiary,
                ),
                _StatChip(
                  label: 'Needs review',
                  value: summary.needsReviewCount,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$value $label', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalAttempts == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Complete a few exercises to see performance stats here.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stats.assessmentAccuracy != null)
          _MetricRow(
            label: 'Assessment accuracy',
            value: stats.assessmentAccuracy!,
          ),
        if (stats.codingPerformance != null)
          _MetricRow(
            label: 'Coding performance',
            value: stats.codingPerformance!,
          ),
        if (stats.explanationPerformance != null)
          _MetricRow(
            label: 'Explanation performance',
            value: stats.explanationPerformance!,
          ),
        if (stats.recentImprovementDelta != null)
          _ImprovementRow(delta: stats.recentImprovementDelta!),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LabeledProgressBar(label: label, progress: value),
    );
  }
}

class _ImprovementRow extends StatelessWidget {
  const _ImprovementRow({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final improving = delta > 0.02;
    final declining = delta < -0.02;
    final color = improving
        ? theme.colorScheme.primary
        : declining
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    final icon = improving
        ? Icons.trending_up
        : declining
        ? Icons.trending_down
        : Icons.trending_flat;
    final label = improving
        ? 'Improving recently'
        : declining
        ? 'Dipped recently'
        : 'Holding steady';

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
