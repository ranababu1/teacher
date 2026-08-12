import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';

/// A focused, exercises-only view for repeat practice on a concept a
/// learner has already been taught — no lesson prose, just "Try It" again.
class PracticeSessionScreen extends ConsumerWidget {
  const PracticeSessionScreen({super.key, required this.conceptId});

  final String conceptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptValue = ref.watch(conceptProvider(conceptId));

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: SafeArea(
        child: AsyncValueView(
          value: conceptValue,
          onRetry: () => ref.invalidate(conceptProvider(conceptId)),
          data: (concept) {
            if (concept == null) {
              return const Center(child: Text('Concept not found.'));
            }
            final language = languageForLearningPathId(concept.learningPathId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  concept.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${concept.exercises.length} exercises',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final exercise in concept.exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExercisePlayer(
                      conceptId: concept.id,
                      language: language,
                      item: PracticeItem.fromExercise(exercise),
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
