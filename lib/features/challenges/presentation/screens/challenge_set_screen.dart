import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../domain/challenge_service.dart';
import '../providers/challenge_providers.dart';

/// A set of three challenges of one kind from one course, played with the
/// standard exercise player (hints, model solution, attempt recording).
class ChallengeSetScreen extends ConsumerWidget {
  const ChallengeSetScreen({
    super.key,
    required this.pathId,
    required this.kindName,
  });

  final String pathId;
  final String kindName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ChallengeKind.fromName(kindName);
    if (kind == null) {
      return Scaffold(
        appBar: GlassAppBar(title: const Text('Challenges')),
        body: const EmptyState(message: 'Unknown challenge type.'),
      );
    }
    final args = (pathId: pathId, kind: kind);
    final value = ref.watch(challengeSetProvider(args));
    return Scaffold(
      appBar: GlassAppBar(title: Text(kind.title)),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(challengeSetProvider(args)),
          data: (set) {
            if (set == null || set.challenges.isEmpty) {
              return const EmptyState(
                message: 'No challenges of this type in this course yet.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (i, c) in set.challenges.indexed) ...[
                  Text(
                    'Challenge ${i + 1} of ${set.challenges.length} · '
                    '${c.concept.title}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ExercisePlayer(
                    key: ValueKey(c.exercise.id),
                    conceptId: c.concept.id,
                    language: languageForLearningPathId(set.path.id),
                    item: PracticeItem.fromExercise(c.exercise),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.goBack(
                          fallbackLocation: Routes.challengeLab,
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            ref.invalidate(challengeSetProvider(args)),
                        child: const Text('New Set'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
