import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/models/project_overview.dart';
import '../providers/project_providers.dart';

/// Lists guided projects with milestone progress and readiness.
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(projectOverviewsProvider);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Projects')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(projectOverviewsProvider),
          skeleton: () => const SkeletonCardList(),
          data: (projects) {
            if (projects.isEmpty) {
              return const EmptyState(
                message: 'No projects are available yet.',
                icon: Icons.construction_outlined,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Build something real. Work through each milestone in '
                  'your own editor, tick it off here, then review your work '
                  'against the rubric.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                for (final o in projects) _ProjectTile(overview: o),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.overview});

  final ProjectOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = overview.project;
    final status = overview.isComplete
        ? 'Completed'
        : overview.isStarted
        ? '${overview.completedCount}/${overview.totalCount} milestones'
        : overview.isRecommendedTopicPassed
        ? 'Ready to start'
        : 'Best after "${overview.recommendedTopicTitle}"';
    return GradientCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        key: ValueKey('project-${p.id}'),
        onTap: () => context.openProject(p.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    overview.isComplete
                        ? Icons.verified_outlined
                        : Icons.construction_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(p.title, style: theme.textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${overview.courseTitle} · ${p.difficulty.label} · '
                '~${p.estimatedHours} h',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(p.summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: overview.fraction),
              const SizedBox(height: 6),
              Text(status, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
