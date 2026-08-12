import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';
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
            final masteryByConceptId = {
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
                    DifficultyChip(difficulty: path.difficulty),
                    const SizedBox(width: 8),
                    Text(
                      '${path.conceptCount} concepts · ~${path.estimatedHours}h',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (final module in path.modules) ...[
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () =>
                          context.go(Routes.module(path.id, module.id)),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
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
                                    (c) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MasteryStatusIcon(
                                          status:
                                              masteryByConceptId[c.id]
                                                  ?.status ??
                                              MasteryStatus.notStarted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(c.title),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
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
