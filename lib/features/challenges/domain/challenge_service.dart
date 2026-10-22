import 'dart:math';

import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/exercise.dart';
import '../../curriculum/domain/models/item_type.dart';
import '../../curriculum/domain/models/learning_path.dart';

/// The kinds of hands-on challenge the Challenge Lab offers, each backed
/// by an exercise type that already ships in the curriculum.
enum ChallengeKind {
  debugging(
    ItemType.debugging,
    'Debugging Sessions',
    'Find and fix the bug in real-looking code.',
  ),
  coding(
    ItemType.coding,
    'Coding Challenges',
    'Write a solution, then compare with a model answer.',
  ),
  scenario(
    ItemType.scenario,
    'Real-World Scenarios',
    'Reason through a production-style problem.',
  );

  const ChallengeKind(this.itemType, this.title, this.description);

  final ItemType itemType;
  final String title;
  final String description;

  static ChallengeKind? fromName(String name) =>
      values.where((k) => k.name == name).firstOrNull;
}

/// One challenge: an exercise plus the concept it belongs to.
typedef Challenge = ({Concept concept, Exercise exercise});

/// Builds Challenge Lab sets from curriculum exercises (offline).
class ChallengeService {
  ChallengeService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const setSize = 3;

  List<Challenge> challenges(LearningPath path, ChallengeKind kind) => [
    for (final concept in path.allConcepts)
      for (final exercise in concept.exercises)
        if (exercise.type == kind.itemType)
          (concept: concept, exercise: exercise),
  ];

  /// Counts per kind for [path] (kinds with zero are included).
  Map<ChallengeKind, int> counts(LearningPath path) => {
    for (final kind in ChallengeKind.values)
      kind: challenges(path, kind).length,
  };

  /// A random set of up to [setSize] challenges from distinct concepts
  /// where possible, ordered by difficulty level (easier first).
  List<Challenge> buildSet(LearningPath path, ChallengeKind kind) {
    final pool = challenges(path, kind)..shuffle(_random);
    final picked = <Challenge>[];
    final concepts = <String>{};
    for (final c in pool) {
      if (picked.length >= setSize) break;
      if (concepts.add(c.concept.id)) picked.add(c);
    }
    for (final c in pool) {
      if (picked.length >= setSize) break;
      if (!picked.contains(c)) picked.add(c);
    }
    picked.sort(
      (a, b) => (a.exercise.difficultyLevel ?? 0).compareTo(
        b.exercise.difficultyLevel ?? 0,
      ),
    );
    return picked;
  }
}
