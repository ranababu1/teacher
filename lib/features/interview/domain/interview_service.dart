import 'dart:math';

import '../../curriculum/domain/models/item_type.dart';
import '../../curriculum/domain/models/learning_path.dart';
import 'models/interview.dart';

/// Builds interview-practice sessions from the bundled curriculum's
/// explanation and scenario assessments (offline, no AI needed).
class InterviewService {
  InterviewService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const defaultSessionLength = 5;

  /// Every interview-style question in [path], in course order.
  List<InterviewQuestion> questionBank(LearningPath path) => [
    for (final module in path.modules)
      for (final concept in module.concepts)
        for (final a in concept.assessments)
          if ((a.type == ItemType.explanation || a.type == ItemType.scenario) &&
              (a.modelAnswer?.trim().isNotEmpty ?? false))
            InterviewQuestion(
              id: a.id,
              learningPathId: path.id,
              moduleId: module.id,
              moduleTitle: module.title,
              conceptId: concept.id,
              conceptTitle: concept.title,
              prompt: a.prompt,
              modelAnswer: a.modelAnswer!,
              isScenario: a.type == ItemType.scenario,
            ),
  ];

  /// A random session of up to [length] questions. Scenario questions are
  /// favoured (at most two per session) because they read most like a
  /// real interview; the rest are drawn from distinct topics where
  /// possible so a session covers breadth.
  List<InterviewQuestion> buildSession(
    LearningPath path, {
    int length = defaultSessionLength,
  }) {
    final bank = questionBank(path)..shuffle(_random);
    final picked = <InterviewQuestion>[
      ...bank.where((q) => q.isScenario).take(2),
    ];
    final usedTopics = {for (final q in picked) q.moduleId};
    for (final q in bank) {
      if (picked.length >= length) break;
      if (picked.contains(q) || usedTopics.contains(q.moduleId)) continue;
      picked.add(q);
      usedTopics.add(q.moduleId);
    }
    for (final q in bank) {
      if (picked.length >= length) break;
      if (!picked.contains(q)) picked.add(q);
    }
    return picked.take(length).toList();
  }
}
