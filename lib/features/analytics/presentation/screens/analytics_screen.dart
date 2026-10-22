import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../domain/models/learning_analytics.dart';
import '../providers/analytics_providers.dart';

/// Learning analytics from real attempt history: activity, accuracy
/// trend, per-course accuracy, weak spots and preferred study time.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(learningAnalyticsProvider);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Learning Analytics')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(learningAnalyticsProvider),
          data: (a) => a.isEmpty
              ? const EmptyState(
                  message:
                      'Answer a few exercises or questions and your learning '
                      'analytics will appear here.',
                  icon: Icons.query_stats_outlined,
                )
              : _AnalyticsBody(analytics: a),
        ),
      ),
    );
  }
}

String _pct(double? v) => v == null ? '-' : '${(v * 100).round()}%';

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.analytics});

  final LearningAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = analytics;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Metric(label: 'Answers', value: '${a.totalAttempts}'),
            _Metric(label: 'Active days (28d)', value: '${a.activeDaysLast28}'),
            _Metric(
              label: 'Usual study time',
              value: a.favouriteDayPart?.label.split(' ').first ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionLabel('Last 28 days'),
        const SizedBox(height: 12),
        _ActivityChart(days: a.last28Days),
        const SizedBox(height: 4),
        Text(
          'Bar height is answers per day; the filled part is answers that '
          'met the success bar.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        const SectionLabel('Accuracy by week'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < a.weekly.length; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _pct(a.weekly[i].accuracy),
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      i == a.weekly.length - 1
                          ? 'This week'
                          : '${a.weekly.length - 1 - i}w ago',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${a.weekly[i].attempts} answers',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (a.courses.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionLabel('By course'),
          const SizedBox(height: 12),
          for (final c in a.courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(c.title)),
                      Text('${_pct(c.accuracy)} · ${c.attempts} answers'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: c.accuracy),
                ],
              ),
            ),
        ],
        const SizedBox(height: 12),
        const SectionLabel('Weak spots'),
        const SizedBox(height: 12),
        if (a.weakConcepts.isEmpty)
          const Text(
            'No weak spots yet: nothing you have tried twice or more is '
            'below 100%.',
          )
        else
          for (final w in a.weakConcepts)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(w.title),
                subtitle: Text(
                  '${_pct(w.accuracy)} over ${w.attempts} answers',
                ),
                trailing: const Icon(Icons.menu_book_outlined),
                onTap: () => context.openLesson(
                  w.learningPathId,
                  w.moduleId,
                  w.conceptId,
                ),
              ),
            ),
        const SizedBox(height: 24),
        const SectionLabel('When you study'),
        const SizedBox(height: 12),
        for (final part in DayPart.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 150, child: Text(part.label)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: a.totalAttempts == 0
                        ? 0
                        : a.attemptsByDayPart[part]! / a.totalAttempts,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${a.attemptsByDayPart[part]}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: theme.textTheme.headlineSmall),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.days});

  final List<DailyActivity> days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxAttempts = days.fold(1, (m, d) => d.attempts > m ? d.attempts : m);
    const height = 96.0;
    return Semantics(
      label:
          'Answers per day for the last 28 days, '
          '${days.where((d) => d.attempts > 0).length} active days',
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final d in days)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    height: d.attempts == 0
                        ? 3
                        : height * d.attempts / maxAttempts,
                    decoration: BoxDecoration(
                      color: d.attempts == 0
                          ? scheme.surfaceContainerHighest
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: d.attempts == 0
                        ? null
                        : FractionallySizedBox(
                            heightFactor: d.successes / d.attempts,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
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
