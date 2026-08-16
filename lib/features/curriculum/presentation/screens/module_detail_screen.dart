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
import '../widgets/course_locked_state.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({
    super.key,
    required this.pathId,
    required this.moduleId,
  });

  final String pathId;
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathValue = ref.watch(learningPathProvider(pathId));
    final masteryValue = ref.watch(allMasteryProvider);
    final isStarted =
        ref.watch(isLearningPathStartedProvider(pathId)).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Topic')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathValue,
          onRetry: () => ref.invalidate(learningPathProvider(pathId)),
          data: (path) {
            final module = path?.findModule(moduleId);
            if (path == null || module == null) {
              return const Center(child: Text('Topic not found.'));
            }
            if (!isStarted) {
              return CourseLockedState(pathId: pathId);
            }
            final masteryByConceptId = {
              for (final m in masteryValue.valueOrNull ?? const [])
                m.conceptId: m,
            };

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  module.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  '${module.concepts.length} concepts',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                for (final concept in module.concepts) ...[
                  Card(
                    child: ListTile(
                      onTap: () => context.go(
                        Routes.lesson(pathId, moduleId, concept.id),
                      ),
                      leading: MasteryStatusIcon(
                        status:
                            masteryByConceptId[concept.id]?.status ??
                            MasteryStatus.notStarted,
                        size: 22,
                      ),
                      title: Text(concept.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(concept.description),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DifficultyChip(difficulty: concept.difficulty),
                              const SizedBox(width: 8),
                              Text(
                                '${concept.estimatedMinutes} min',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
