import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/models/project_overview.dart';
import '../providers/project_providers.dart';

/// Brief, milestone checklist, self-review rubric and stretch goals.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(projectOverviewProvider(projectId));
    return Scaffold(
      appBar: GlassAppBar(
        title: Text(value.valueOrNull?.project.title ?? 'Project'),
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(projectOverviewProvider(projectId)),
          skeleton: () => const SkeletonCardList(),
          data: (overview) {
            if (overview == null) {
              return const EmptyState(
                message: "We couldn't find that project.",
                icon: Icons.construction_outlined,
              );
            }
            return _ProjectBody(overview: overview);
          },
        ),
      ),
    );
  }
}

class _ProjectBody extends ConsumerWidget {
  const _ProjectBody({required this.overview});

  final ProjectOverview overview;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    String milestoneId,
    bool completed,
  ) async {
    try {
      await ref.read(projectMilestoneTogglerProvider)(
        projectId: overview.project.id,
        milestoneId: milestoneId,
        completed: completed,
      );
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = overview.project;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${overview.courseTitle} · ${p.difficulty.label} · '
          '~${p.estimatedHours} h',
          style: theme.textTheme.bodySmall,
        ),
        if (!overview.isRecommendedTopicPassed &&
            overview.recommendedTopicTitle != null) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              title: Text(
                'Best after passing the "${overview.recommendedTopicTitle}" '
                'test. You can still start now.',
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          ),
        ],
        if (p.skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in p.skills)
                Chip(label: Text(s), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
        const SizedBox(height: 12),
        GradientCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownText(data: p.brief),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Milestones', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text(
              '${overview.completedCount}/${overview.totalCount}',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: overview.fraction),
        const SizedBox(height: 8),
        for (final (i, m) in p.milestones.indexed)
          GradientCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              key: ValueKey('milestone-${m.id}'),
              value: overview.completedMilestoneIds.contains(m.id),
              onChanged: (v) => _toggle(context, ref, m.id, v ?? false),
              title: Text('${i + 1}. ${m.title}'),
              subtitle: Text(m.description),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        if (overview.isComplete) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.celebration_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'All milestones done. Review your work against the rubric '
                'below, then try a stretch goal.',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
        ],
        if (p.rubric.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Self-review rubric', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final r in p.rubric)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.checklist_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(r.criterion),
                subtitle: Text(r.lookFor),
              ),
            ),
        ],
        if (p.stretchGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Stretch goals', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final g in p.stretchGoals)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(g)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
