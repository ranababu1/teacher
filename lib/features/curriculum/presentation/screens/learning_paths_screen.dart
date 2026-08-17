import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/utils/subject_style.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../progress/domain/models/path_progress_summary.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/models/learning_path.dart';
import '../curriculum_providers.dart';

class LearningPathsScreen extends ConsumerWidget {
  const LearningPathsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsValue = ref.watch(learningPathsProvider);
    final summariesValue = ref.watch(pathProgressSummariesProvider);

    return Scaffold(
      appBar: GlassAppBar(title: const Text('Learning Paths')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathsValue,
          onRetry: () => ref.invalidate(learningPathsProvider),
          skeleton: () =>
              const SkeletonCardList(itemCount: 6, itemHeight: 190),
          data: (paths) {
            final summaries = summariesValue.valueOrNull;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 190,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: paths.length,
              itemBuilder: (context, index) {
                final path = paths[index];
                final summary = summaries?.firstWhere(
                  (s) => s.learningPathId == path.id,
                  orElse: () => PathProgressSummary(
                    learningPathId: path.id,
                    title: path.title,
                    totalConcepts: path.conceptCount,
                    overallPercent: 0,
                    statusCounts: const {},
                  ),
                );
                return FadeSlideIn(
                  index: index,
                  child: _LearningPathCard(path: path, summary: summary),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  const _LearningPathCard({required this.path, this.summary});

  final LearningPath path;
  final PathProgressSummary? summary;

  bool get _isComingSoon => path.modules.isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = subjectColor(path.id, theme.brightness);

    return Opacity(
      opacity: _isComingSoon ? 0.7 : 1,
      child: GradientCard(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go(Routes.learningPath(path.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(subjectIcon(path.iconName), color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        path.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  path.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_isComingSoon)
                  Chip(
                    label: const Text('Coming Soon'),
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    labelStyle: theme.textTheme.labelMedium,
                    visualDensity: VisualDensity.compact,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: LabeledProgressBar(
                          label: '${path.conceptCount} concepts',
                          progress: summary?.overallPercent ?? 0,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                if (!_isComingSoon) ...[
                  const SizedBox(height: 8),
                  DifficultyChip(difficulty: path.difficulty),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
