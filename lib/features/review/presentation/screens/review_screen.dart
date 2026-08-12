import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../providers/review_providers.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueValue = ref.watch(dueForReviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(
        child: AsyncValueView(
          value: dueValue,
          onRetry: () => ref.invalidate(dueForReviewProvider),
          data: (concepts) {
            if (concepts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "You're all caught up — nothing due for review right now.",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${concepts.length} concept${concepts.length == 1 ? '' : 's'} due for review',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final concept in concepts)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.replay_circle_filled_outlined),
                      title: Text(concept.title),
                      subtitle: Text(concept.description),
                      trailing: FilledButton(
                        onPressed: () => context.push('/review/${concept.id}'),
                        child: const Text('Review'),
                      ),
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
