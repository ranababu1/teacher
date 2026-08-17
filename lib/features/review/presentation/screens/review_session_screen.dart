import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';

/// A short, focused review flow for one concept: recall question -> answer
/// -> feedback -> confidence rating. See instructions.md section 35.
///
/// Prefers an assessment item (it's what schedules the next review inside
/// [RecordAttemptUseCase]); falls back to an exercise if the concept has
/// no assessments authored yet.
class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({super.key, required this.conceptId});

  final String conceptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptValue = ref.watch(conceptProvider(conceptId));

    return Scaffold(
      appBar: GlassAppBar(title: const Text('Review')),
      body: SafeArea(
        child: AsyncValueView(
          value: conceptValue,
          onRetry: () => ref.invalidate(conceptProvider(conceptId)),
          data: (concept) {
            if (concept == null) {
              return const Center(child: Text('Concept not found.'));
            }

            final item = concept.assessments.isNotEmpty
                ? PracticeItem.fromAssessment(concept.assessments.first)
                : concept.exercises.isNotEmpty
                ? PracticeItem.fromExercise(concept.exercises.first)
                : null;

            if (item == null) {
              return const Center(
                child: Text('Nothing to review for this concept yet.'),
              );
            }

            final language = languageForLearningPathId(concept.learningPathId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  concept.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ExercisePlayer(
                  conceptId: concept.id,
                  language: language,
                  item: item,
                  onCompleted: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Next review scheduled.')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
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
