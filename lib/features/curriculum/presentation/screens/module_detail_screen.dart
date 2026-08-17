import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../progress/domain/models/mastery_status.dart';
import '../../../progress/domain/module_unlock.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/mastery_status_icon.dart';
import '../curriculum_providers.dart';
import '../widgets/course_locked_state.dart';
import '../widgets/topic_locked_state.dart';

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
    final passedModuleIds =
        ref.watch(passedModuleIdsProvider(pathId)).valueOrNull ?? const {};

    return Scaffold(
      appBar: GlassAppBar(title: const Text('Topic')),
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
            if (!isModuleUnlocked(
              path: path,
              module: module,
              passedModuleIds: passedModuleIds,
            )) {
              final index = path.modules.indexWhere((m) => m.id == module.id);
              return TopicLockedState(
                pathId: pathId,
                previousModuleId: path.modules[index - 1].id,
              );
            }
            final masteryByConceptId = {
              for (final m in masteryValue.valueOrNull ?? const [])
                m.conceptId: m,
            };
            final isPassed = passedModuleIds.contains(module.id);
            final next = nextModule(path: path, module: module);

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
                  GradientCard(
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
                const SizedBox(height: 12),
                _TopicTestCta(
                  pathId: pathId,
                  moduleId: moduleId,
                  isPassed: isPassed,
                  nextModuleId: next?.id,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopicTestCta extends StatelessWidget {
  const _TopicTestCta({
    required this.pathId,
    required this.moduleId,
    required this.isPassed,
    required this.nextModuleId,
  });

  final String pathId;
  final String moduleId;
  final bool isPassed;
  final String? nextModuleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPassed) {
      return GradientCard(
        child: ListTile(
          leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
          title: const Text('Topic test passed'),
          trailing: nextModuleId == null
              ? null
              : FilledButton(
                  // push, not go: this module and the next one are
                  // siblings (same route depth) — go() would rebuild the
                  // whole branch stack from this URI and discard the
                  // current module page, so swiping back would skip
                  // straight past it to the path detail screen instead
                  // of landing back here.
                  onPressed: () =>
                      context.push(Routes.module(pathId, nextModuleId!)),
                  child: const Text('Continue'),
                ),
        ),
      );
    }

    return GradientCard(
      child: ListTile(
        leading: Icon(Icons.quiz_outlined, color: theme.colorScheme.primary),
        title: const Text('Topic test'),
        subtitle: const Text(
          'Pass this to unlock the next topic.',
        ),
        trailing: FilledButton(
          onPressed: () => context.go(Routes.moduleTest(pathId, moduleId)),
          child: const Text('Take Topic Test'),
        ),
      ),
    );
  }
}
