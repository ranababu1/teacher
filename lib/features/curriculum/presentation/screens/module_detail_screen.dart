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
                      subtitle: Text(concept.description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DifficultyChip(difficulty: concept.difficulty),
                          const SizedBox(height: 4),
                          Text(
                            '${concept.estimatedMinutes} min',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
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
