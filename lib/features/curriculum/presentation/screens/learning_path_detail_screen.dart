import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../progress/domain/models/concept_mastery.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/domain/module_unlock.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/models/curriculum_module.dart';
import '../../domain/models/learning_path.dart';
import '../curriculum_providers.dart';
import '../../../../app/navigation.dart';

class LearningPathDetailScreen extends ConsumerWidget {
  const LearningPathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathValue = ref.watch(learningPathProvider(pathId));
    final masteryValue = ref.watch(allMasteryProvider);
    final isStarted =
        ref.watch(isLearningPathStartedProvider(pathId)).valueOrNull ?? false;
    final passedModuleIds =
        ref.watch(passedModuleIdsProvider(pathId)).valueOrNull ?? const {};

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(pathId[0].toUpperCase() + pathId.substring(1)),
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: pathValue,
          onRetry: () => ref.invalidate(learningPathProvider(pathId)),
          data: (path) {
            if (path == null) {
              return const Center(child: Text('Learning path not found.'));
            }
            final masteryByConceptId = <String, ConceptMastery>{
              for (final m in masteryValue.valueOrNull ?? const [])
                m.conceptId: m,
            };

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  path.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  path.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (path.modules.isEmpty)
                      Chip(
                        label: const Text('Coming Soon'),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        visualDensity: VisualDensity.compact,
                      )
                    else ...[
                      DifficultyChip(difficulty: path.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        '${path.conceptCount} concepts · ~${path.estimatedHours}h',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (path.modules.isNotEmpty && !isStarted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilledButton.icon(
                          onPressed: () => ref
                              .read(learningPathStarterProvider)
                              .call(path.id),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Course'),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start this course to unlock its lessons.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (path.modules.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GradientCard(
                      child: ListTile(
                        leading: Icon(
                          Icons.fact_check_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Already know some of this?'),
                        subtitle: const Text(
                          'Take a 5-minute skill check to find where to start.',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.openSkillCheck(path.id),
                      ),
                    ),
                  ),
                if (path.modules.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Curriculum for ${path.title} is in the works.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check back soon — this path will fill in without needing an app update.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  for (var i = 0; i < path.modules.length; i++) ...[
                    FadeSlideIn(
                      index: i,
                      child: _ModuleCard(
                        path: path,
                        module: path.modules[i],
                        masteryByConceptId: masteryByConceptId,
                        isStarted: isStarted,
                        passedModuleIds: passedModuleIds,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                _CourseProjectsSection(pathId: path.id),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Guided projects for this course. Secondary content, so it simply stays
/// hidden while loading, on error, or when the course has none.
class _CourseProjectsSection extends ConsumerWidget {
  const _CourseProjectsSection({required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = (ref.watch(projectOverviewsProvider).valueOrNull ?? [])
        .where((o) => o.project.learningPathId == pathId)
        .toList();
    if (projects.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Projects', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final o in projects)
          GradientCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                o.isComplete
                    ? Icons.verified_outlined
                    : Icons.construction_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(o.project.title),
              subtitle: Text(
                o.isStarted
                    ? '${o.completedCount}/${o.totalCount} milestones'
                    : o.isRecommendedTopicPassed
                    ? 'Ready to start · ~${o.project.estimatedHours} h'
                    : 'Best after "${o.recommendedTopicTitle}"',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.openProject(o.project.id),
            ),
          ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.path,
    required this.module,
    required this.masteryByConceptId,
    required this.isStarted,
    required this.passedModuleIds,
  });

  final LearningPath path;
  final CurriculumModule module;
  final Map<String, ConceptMastery> masteryByConceptId;
  final bool isStarted;
  final Set<String> passedModuleIds;

  @override
  Widget build(BuildContext context) {
    final isUnlocked =
        isStarted &&
        isModuleUnlocked(
          path: path,
          module: module,
          passedModuleIds: passedModuleIds,
        );

    return Opacity(
      opacity: isUnlocked ? 1 : 0.5,
      child: GradientCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isStarted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start this course to unlock its lessons.'),
                ),
              );
              return;
            }
            if (!isUnlocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Pass the previous topic's test to unlock this topic.",
                  ),
                ),
              );
              return;
            }
            context.openTopic(path.id, module.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        module.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(isUnlocked ? Icons.chevron_right : Icons.lock_outline),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: module.concepts
                      .map(
                        (c) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MasteryStatusIcon(
                                status:
                                    masteryByConceptId[c.id]?.status ??
                                    MasteryStatus.notStarted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  c.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
