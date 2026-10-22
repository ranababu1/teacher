import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/coding_challenge_providers.dart';

/// Lists long-form, multi-part coding challenges with best scores.
class CodingChallengeListScreen extends ConsumerWidget {
  const CodingChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(codingChallengeListProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Long-form Challenges')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(codingChallengeListProvider),
          skeleton: () => const SkeletonCardList(),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                message: 'No long-form challenges yet.',
                icon: Icons.terminal_outlined,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Bigger problems solved in parts, each building on the '
                  'last. Write your code in the app or your editor, check '
                  'the listed behaviours, then compare with the reference.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                for (final item in items)
                  GradientCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      key: ValueKey('challenge-${item.challenge.id}'),
                      onTap: () =>
                          context.openCodingChallenge(item.challenge.id),
                      leading: Icon(
                        item.record == null
                            ? Icons.terminal_outlined
                            : Icons.verified_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(item.challenge.title),
                      subtitle: Text(
                        '${item.courseTitle} · '
                        '${item.challenge.parts.length} parts · '
                        '~${item.challenge.estimatedMinutes} min'
                        '${item.record == null ? '' : ' · Best ${item.record!.bestPercent}%'}'
                        '\n${item.challenge.summary}',
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
