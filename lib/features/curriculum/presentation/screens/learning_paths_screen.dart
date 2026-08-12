import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
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
      appBar: AppBar(title: const Text('Learning Paths')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathsValue,
          onRetry: () => ref.invalidate(learningPathsProvider),
          data: (paths) {
            final summaries = summariesValue.valueOrNull;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: paths.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                return _LearningPathCard(path: path, summary: summary);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(Routes.learningPath(path.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(path.title, style: theme.textTheme.titleLarge),
                  ),
                  DifficultyChip(difficulty: path.difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Text(path.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              LabeledProgressBar(
                label:
                    '${path.conceptCount} concepts · ~${path.estimatedHours}h',
                progress: summary?.overallPercent ?? 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
