import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/learning_path.dart';
import '../../progress/domain/models/concept_mastery.dart';
import '../../progress/domain/models/mastery_status.dart';
import 'models/dashboard_recommendation.dart';

/// Rule-based "what to learn next" — deliberately not AI-generated in v1.
/// See instructions.md section 8: the eventual version should be
/// AI-generated with a short explanation; this heuristic (first
/// not-yet-started concept whose prerequisites are already solid) gives
/// the same shape of recommendation honestly, without pretending to be AI.
class RecommendationService {
  DashboardRecommendation? recommendNext({
    required List<LearningPath> paths,
    required Map<String, ConceptMastery> masteryByConceptId,
  }) {
    final conceptsById = <String, Concept>{
      for (final path in paths)
        for (final concept in path.allConcepts) concept.id: concept,
    };

    bool isSolid(String conceptId) {
      final status = masteryByConceptId[conceptId]?.status;
      return status == MasteryStatus.proficient ||
          status == MasteryStatus.mastered;
    }

    for (final path in paths) {
      for (final module in path.modules) {
        for (final concept in module.concepts) {
          final status =
              masteryByConceptId[concept.id]?.status ??
              MasteryStatus.notStarted;
          if (status != MasteryStatus.notStarted) continue;

          final prereqsMet = concept.prerequisites.every(isSolid);
          if (!prereqsMet) continue;

          final reason = concept.prerequisites.isEmpty
              ? 'A great starting point for ${path.title}.'
              : "You've built a solid foundation in "
                    '${concept.prerequisites.map((id) => conceptsById[id]?.title ?? id).join(', ')} '
                    '— this builds directly on that.';

          return DashboardRecommendation(
            concept: concept,
            learningPathTitle: path.title,
            moduleTitle: module.title,
            reason: reason,
          );
        }
      }
    }
    return null;
  }
}
