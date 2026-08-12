import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsValue = ref.watch(learningPathsProvider);
    final masteryValue = ref.watch(allMasteryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathsValue,
          onRetry: () => ref.invalidate(learningPathsProvider),
          data: (paths) {
            final masteryByConceptId = {
              for (final m in masteryValue.valueOrNull ?? const [])
                m.conceptId: m,
            };
            final practicable = paths
                .where((p) => p.allConcepts.any((c) => c.exercises.isNotEmpty))
                .toList();

            if (practicable.isEmpty) {
              return const Center(
                child: Text('No practice exercises available yet.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final path in practicable) ...[
                  Text(
                    path.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  for (final concept in path.allConcepts.where(
                    (c) => c.exercises.isNotEmpty,
                  ))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => context.push('/practice/${concept.id}'),
                        leading: MasteryStatusIcon(
                          status:
                              masteryByConceptId[concept.id]?.status ??
                              MasteryStatus.notStarted,
                          size: 22,
                        ),
                        title: Text(concept.title),
                        subtitle: Text('${concept.exercises.length} exercises'),
                        trailing: DifficultyChip(
                          difficulty: concept.difficulty,
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
