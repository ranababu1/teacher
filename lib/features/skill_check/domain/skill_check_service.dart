import 'dart:math';

import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/item_type.dart';
import '../../curriculum/domain/models/learning_path.dart';
import 'models/skill_check.dart';

/// Builds and scores course skill checks from the bundled curriculum's
/// multiple-choice assessments (offline, no AI needed).
class SkillCheckService {
  SkillCheckService({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Upper bound on questions so a check stays a few minutes long.
  static const maxQuestions = 16;

  /// Picks questions in course order: two per topic for short courses,
  /// one per topic otherwise, capped at [maxQuestions] by sampling topics
  /// evenly across the course.
  List<SkillCheckQuestion> buildQuestions(LearningPath path) {
    final topicsWithQuestions = [
      for (final module in path.modules)
        if (_candidates(module.concepts).isNotEmpty) module,
    ];
    if (topicsWithQuestions.isEmpty) return const [];

    final perTopic = topicsWithQuestions.length * 2 <= maxQuestions ? 2 : 1;
    final topics = topicsWithQuestions.length <= maxQuestions
        ? topicsWithQuestions
        : [
            for (var i = 0; i < maxQuestions; i++)
              topicsWithQuestions[(i * topicsWithQuestions.length) ~/
                  maxQuestions],
          ];

    final questions = <SkillCheckQuestion>[];
    for (final module in topics) {
      final pool = _candidates(module.concepts)..shuffle(_random);
      for (final pick in pool.take(perTopic)) {
        questions.add(
          SkillCheckQuestion(
            moduleId: module.id,
            moduleTitle: module.title,
            conceptId: pick.conceptId,
            assessment: pick.assessment,
          ),
        );
      }
    }
    return questions;
  }

  /// Scores [answers] (question id -> selected option index; missing means
  /// unanswered) and derives the placement.
  SkillCheckResult score({
    required LearningPath path,
    required List<SkillCheckQuestion> questions,
    required Map<String, int> answers,
  }) {
    final topicScores = <SkillCheckTopicScore>[];
    for (final module in path.modules) {
      final asked = questions.where((q) => q.moduleId == module.id).toList();
      if (asked.isEmpty) continue;
      topicScores.add(
        SkillCheckTopicScore(
          module: module,
          correct: asked.where((q) => q.isCorrect(answers[q.id])).length,
          total: asked.length,
        ),
      );
    }

    // Placement only skips a leading run of topics that were asked AND
    // answered perfectly; a topic that was not sampled stops the run, so
    // the learner is never moved past material that was not checked.
    final testedOut = <String>[];
    for (final module in path.modules) {
      final score = topicScores.where((t) => t.module.id == module.id);
      if (score.isEmpty || !score.first.isAllCorrect) break;
      testedOut.add(module.id);
    }
    final recommended = path.modules
        .where((m) => !testedOut.contains(m.id))
        .firstOrNull;

    return SkillCheckResult(
      learningPathId: path.id,
      topicScores: topicScores,
      testedOutModuleIds: testedOut,
      recommendedStartModule: recommended,
    );
  }

  List<({String conceptId, Assessment assessment})> _candidates(
    Iterable<Concept> concepts,
  ) => [
    for (final concept in concepts)
      for (final a in concept.assessments)
        if (a.type == ItemType.multipleChoice &&
            (a.options?.length ?? 0) >= 2 &&
            a.correctOptionIndex != null)
          (conceptId: concept.id, assessment: a),
  ];
}
