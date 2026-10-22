import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../domain/challenge_service.dart';

final challengeServiceProvider = Provider<ChallengeService>(
  (ref) => ChallengeService(),
);

/// Courses that have at least one challenge, with counts per kind.
final challengeCoursesProvider =
    FutureProvider<List<({LearningPath path, Map<ChallengeKind, int> counts})>>(
      (ref) async {
        final paths = await ref.watch(learningPathsProvider.future);
        final service = ref.read(challengeServiceProvider);
        return [
          for (final p in paths)
            if (service.counts(p).values.any((n) => n > 0))
              (path: p, counts: service.counts(p)),
        ];
      },
    );

/// The course picked on the Challenge Lab screen (`null` = first).
final selectedChallengeCourseProvider = StateProvider<String?>((ref) => null);

/// A fresh random set. Auto-disposed so each visit draws new challenges.
final challengeSetProvider = FutureProvider.autoDispose
    .family<
      ({LearningPath path, List<Challenge> challenges})?,
      ({String pathId, ChallengeKind kind})
    >((ref, args) async {
      final path = await ref.watch(learningPathProvider(args.pathId).future);
      if (path == null) return null;
      return (
        path: path,
        challenges: ref
            .read(challengeServiceProvider)
            .buildSet(path, args.kind),
      );
    });
