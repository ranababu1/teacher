import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/concept.dart';

/// What the Dashboard's "Continue Learning" card should show. A sealed
/// result type rather than a nullable `Concept?` — the card has three
/// genuinely distinct states, not "a concept or nothing."
sealed class ContinueLearningState extends Equatable {
  const ContinueLearningState();
}

/// Nothing has ever been started anywhere.
class ContinueLearningEmpty extends ContinueLearningState {
  const ContinueLearningEmpty();

  @override
  List<Object?> get props => [];
}

/// Resume/continue this concept — either the most-recently-accessed one
/// (if not yet completed), or the next incomplete concept in the same
/// path (if the most-recently-accessed one is already done).
class ContinueLearningConcept extends ContinueLearningState {
  const ContinueLearningConcept(this.concept);

  final Concept concept;

  @override
  List<Object?> get props => [concept];
}

/// Every concept in the most-recently-accessed path is complete.
class ContinueLearningPathCompleted extends ContinueLearningState {
  const ContinueLearningPathCompleted({
    required this.pathId,
    required this.pathTitle,
  });

  final String pathId;
  final String pathTitle;

  @override
  List<Object?> get props => [pathId, pathTitle];
}
