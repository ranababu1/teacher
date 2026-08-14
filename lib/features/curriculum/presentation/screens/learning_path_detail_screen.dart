import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../progress/domain/models/concept_mastery.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';
import '../../domain/models/curriculum_module.dart';
import '../../domain/models/learning_path.dart';
import '../curriculum_providers.dart';

class LearningPathDetailScreen extends ConsumerWidget {
  const LearningPathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathValue = ref.watch(learningPathProvider(pathId));
    final masteryValue = ref.watch(allMasteryProvider);

    return Scaffold(
      appBar: AppBar(
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
                const SizedBox(height: 20),
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
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.path,
    required this.module,
    required this.masteryByConceptId,
  });

  final LearningPath path;
  final CurriculumModule module;
  final Map<String, ConceptMastery> masteryByConceptId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(Routes.module(path.id, module.id)),
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
                  const Icon(Icons.chevron_right),
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
    );
  }
}
