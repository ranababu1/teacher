import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/assessment.dart';
import '../../../curriculum/domain/models/curriculum_module.dart';

/// One multiple-choice question in a course skill check, tagged with the
/// topic (module) it probes so the result can be broken down per topic.
class SkillCheckQuestion extends Equatable {
  const SkillCheckQuestion({
    required this.moduleId,
    required this.moduleTitle,
    required this.conceptId,
    required this.assessment,
  });

  final String moduleId;
  final String moduleTitle;
  final String conceptId;

  /// Always a multiple-choice assessment with options and a correct index.
  final Assessment assessment;

  String get id => assessment.id;

  bool isCorrect(int? selectedIndex) =>
      selectedIndex != null && selectedIndex == assessment.correctOptionIndex;

  @override
  List<Object?> get props => [moduleId, conceptId, assessment];
}

/// How the learner did on one topic in a skill check.
class SkillCheckTopicScore extends Equatable {
  const SkillCheckTopicScore({
    required this.module,
    required this.correct,
    required this.total,
  });

  final CurriculumModule module;
  final int correct;
  final int total;

  bool get isAllCorrect => total > 0 && correct == total;

  @override
  List<Object?> get props => [module.id, correct, total];
}

/// The scored outcome of a skill check, including the placement it
/// suggests: the leading run of topics the learner answered perfectly can
/// be skipped, and learning starts at the first topic after that run.
class SkillCheckResult extends Equatable {
  const SkillCheckResult({
    required this.learningPathId,
    required this.topicScores,
    required this.testedOutModuleIds,
    required this.recommendedStartModule,
  });

  final String learningPathId;

  /// In course order; topics without a question are omitted.
  final List<SkillCheckTopicScore> topicScores;

  /// Topics (in course order) the learner can skip: the leading run of
  /// perfectly answered topics, with no unanswered topic in between.
  final List<String> testedOutModuleIds;

  /// Where to start learning, or `null` when every topic was tested out.
  final CurriculumModule? recommendedStartModule;

  int get correct => topicScores.fold(0, (sum, t) => sum + t.correct);
  int get total => topicScores.fold(0, (sum, t) => sum + t.total);
  int get scorePercent => total == 0 ? 0 : (correct * 100 / total).round();

  @override
  List<Object?> get props => [
    learningPathId,
    topicScores,
    testedOutModuleIds,
    recommendedStartModule?.id,
  ];
}
