import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/concept.dart';
import '../../../progress/domain/models/concept_mastery.dart';

/// Everything the AI needs to respond usefully to a single learner
/// interaction. See instructions.md section 20 — "Never send an isolated
/// question to the AI if context is available."
///
/// This is assembled by a use case that reads from the curriculum,
/// progress, and assessment repositories; the AI provider itself never
/// touches those repositories directly.
class TeachingContext extends Equatable {
  const TeachingContext({
    required this.concept,
    required this.prerequisites,
    required this.mastery,
    required this.recentMisconceptions,
    required this.currentDifficultyLevel,
  });

  final Concept concept;
  final List<Concept> prerequisites;
  final ConceptMastery mastery;
  final List<String> recentMisconceptions;
  final int currentDifficultyLevel;

  @override
  List<Object?> get props => [
    concept,
    prerequisites,
    mastery,
    recentMisconceptions,
    currentDifficultyLevel,
  ];
}
