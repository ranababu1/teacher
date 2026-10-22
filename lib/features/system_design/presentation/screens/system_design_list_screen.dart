import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/system_design_providers.dart';

/// Lists the staged system design exercises with best scores.
class SystemDesignListScreen extends ConsumerWidget {
  const SystemDesignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(systemDesignListProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('System Design')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(systemDesignListProvider),
          skeleton: () => const SkeletonCardList(),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                message: 'No system design exercises yet.',
                icon: Icons.account_tree_outlined,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Work through a design the way an interview does: '
                  'requirements, estimates, API, architecture, then the '
                  'hard trade-offs. Compare each stage with a model answer.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                for (final item in items)
                  GradientCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      key: ValueKey('design-${item.exercise.id}'),
                      onTap: () =>
                          context.openSystemDesignExercise(item.exercise.id),
                      leading: Icon(
                        item.record == null
                            ? Icons.account_tree_outlined
                            : Icons.verified_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(item.exercise.title),
                      subtitle: Text(
                        '${item.exercise.summary}\n'
                        '${item.exercise.difficulty.label} · '
                        '~${item.exercise.estimatedMinutes} min'
                        '${item.record == null ? '' : ' · Best ${item.record!.bestPercent}% '
                                  '(${item.record!.attempts}x)'}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
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
