import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';
import '../providers/practice_providers.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsValue = ref.watch(learningPathsProvider);
    final masteryValue = ref.watch(allMasteryProvider);
    final startedIdsValue = ref.watch(startedLearningPathIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathsValue,
          onRetry: () => ref.invalidate(learningPathsProvider),
          skeleton: () => const SkeletonCardList(),
          data: (paths) {
            final masteryByConceptId = {
              for (final m in masteryValue.valueOrNull ?? const [])
                m.conceptId: m,
            };
            final startedIds = startedIdsValue.valueOrNull ?? const <String>{};
            final practicable = paths
                .where(
                  (p) =>
                      startedIds.contains(p.id) &&
                      p.allConcepts.any((c) => c.exercises.isNotEmpty),
                )
                .toList();

            if (practicable.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        startedIds.isEmpty
                            ? 'Start a learning path to practice its exercises.'
                            : 'No practice exercises available yet.',
                        textAlign: TextAlign.center,
                      ),
                      if (startedIds.isEmpty) ...[
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go(Routes.learn),
                          child: const Text('Browse Learning Paths'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            final storedId = ref.watch(selectedPracticePathIdProvider);
            final effectiveId = practicable.any((p) => p.id == storedId)
                ? storedId
                : practicable.first.id;
            final selectedPath = practicable.firstWhere(
              (p) => p.id == effectiveId,
            );
            final practicableConcepts = selectedPath.allConcepts
                .where((c) => c.exercises.isNotEmpty)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(
                      'Course',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: selectedPath.id,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                                  .read(selectedPracticePathIdProvider.notifier)
                                  .state =
                              value;
                        }
                      },
                      items: practicable
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.title),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final concept in practicableConcepts)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () =>
                          context.push(Routes.practiceSession(concept.id)),
                      leading: MasteryStatusIcon(
                        status:
                            masteryByConceptId[concept.id]?.status ??
                            MasteryStatus.notStarted,
                        size: 22,
                      ),
                      title: Text(concept.title),
                      subtitle: Text('${concept.exercises.length} exercises'),
                      trailing: DifficultyChip(difficulty: concept.difficulty),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
