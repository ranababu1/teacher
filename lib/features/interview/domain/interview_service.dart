import 'dart:math';

import '../../curriculum/domain/models/concept.dart';
import '../../curriculum/domain/models/curriculum_module.dart';
import '../../curriculum/domain/models/item_type.dart';
import '../../curriculum/domain/models/learning_path.dart';
import 'models/interview.dart';

/// Builds interview-practice sessions from the bundled curriculum (offline,
/// no AI needed).
class InterviewService {
  InterviewService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const defaultSessionLength = 5;

  /// Questions offered per course.
  static const bankSize = 100;

  /// Up to [bankSize] open-ended questions for [path]. Purpose-written
  /// explanation and scenario questions always come first; the rest reuse
  /// the course's other authored material, one kind at a time. Multiple
  /// choice comes last because those items also appear in topic tests.
  List<InterviewQuestion> questionBank(LearningPath path) {
    final bank = <InterviewQuestion>[];
    final prompts = <String>{};
    for (final source in [
      _authored,
      _debugging,
      _misconceptions,
      _coding,
      _predictOutput,
      _multipleChoice,
    ]) {
      // Takes one per concept per pass, so a partly used source still
      // covers the whole course.
      final byConcept = [
        for (final module in path.modules)
          for (final concept in module.concepts) source(path, module, concept),
      ];
      final ordered = identical(source, _authored)
          ? byConcept.expand((q) => q)
          : _interleave(byConcept);
      for (final q in ordered) {
        if (bank.length >= bankSize) return bank;
        if (prompts.add(q.prompt)) bank.add(q);
      }
    }
    return bank;
  }

  static Iterable<T> _interleave<T>(List<List<T>> lists) sync* {
    final longest = lists.fold(0, (n, l) => max(n, l.length));
    for (var i = 0; i < longest; i++) {
      for (final l in lists) {
        if (i < l.length) yield l[i];
      }
    }
  }

  static InterviewQuestion _question(
    LearningPath path,
    CurriculumModule module,
    Concept concept, {
    required String id,
    required String prompt,
    required String modelAnswer,
    required String label,
    bool isScenario = false,
  }) => InterviewQuestion(
    id: id,
    learningPathId: path.id,
    moduleId: module.id,
    moduleTitle: module.title,
    conceptId: concept.id,
    conceptTitle: concept.title,
    prompt: prompt,
    modelAnswer: modelAnswer,
    isScenario: isScenario,
    label: label,
  );

  static List<InterviewQuestion> _authored(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) => [
    for (final a in concept.assessments)
      if ((a.type == ItemType.explanation || a.type == ItemType.scenario) &&
          _has(a.modelAnswer))
        _question(
          path,
          module,
          concept,
          id: a.id,
          prompt: a.prompt,
          modelAnswer: a.modelAnswer!,
          label: a.type == ItemType.scenario ? 'Scenario' : 'Concept',
          isScenario: a.type == ItemType.scenario,
        ),
  ];

  static List<InterviewQuestion> _misconceptions(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) => [
    for (final (i, m) in concept.misconceptions.indexed)
      if (_has(m.description) && _has(m.clarification))
        _question(
          path,
          module,
          concept,
          id: '${concept.id}-misconception-$i',
          prompt:
              'Here is a common misconception about ${concept.title}:\n\n'
              '"${m.description}"\n\n'
              'What is wrong with it, and what is actually true?',
          modelAnswer: m.clarification,
          label: 'Misconception',
        ),
  ];

  static List<InterviewQuestion> _debugging(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) => _exercises(path, module, concept, ItemType.debugging, 'Debugging');

  static List<InterviewQuestion> _coding(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) => _exercises(path, module, concept, ItemType.coding, 'Coding');

  static List<InterviewQuestion> _predictOutput(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) =>
      _exercises(path, module, concept, ItemType.predictOutput, 'Code reading');

  static List<InterviewQuestion> _exercises(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
    ItemType type,
    String label,
  ) => [
    for (final e in concept.exercises)
      if (e.type == type &&
          _has(e.solutionExplanation) &&
          (_has(e.solutionCode) || _has(e.expectedAnswer)))
        _question(
          path,
          module,
          concept,
          id: e.id,
          prompt: [e.prompt, if (_has(e.code)) _fence(e.code!)].join('\n\n'),
          modelAnswer: [
            if (type == ItemType.predictOutput && _has(e.expectedAnswer))
              _fence(e.expectedAnswer!),
            e.solutionExplanation!,
            if (_has(e.solutionCode)) _fence(e.solutionCode!),
          ].join('\n\n'),
          label: label,
        ),
  ];

  /// Wording that only makes sense with the answer options or the lesson
  /// on screen.
  static final _needsContext = RegExp(
    r'\bwhich (of|one|statement|description|scenario|option|choice|set|pair|'
    r'is the|answer|most)\b|\bfollowing\b|\bthese\b|\bth(is|e) concept\b|'
    r'\blesson\b|\bworked example\b|\bdescribed\b|\bthis module\b|'
    r'\boptions?\b|\bselect (the|all|one)\b|\baccording to\b|\bper (this|the)\b|\bbest\b|'
    r"\bconcept's\b",
    caseSensitive: false,
  );
  static final _leansOnQuiz = RegExp(
    r'\boptions?\b|\bchoices?\b|\bth(is|e) (concept|module|lesson)\b|'
    r"\b(concept|module|lesson)'s\b|\bdistractor|\bother answers?\b|"
    r'\bthis (question )?tests\b|\bworked example\b',
    caseSensitive: false,
  );

  static List<InterviewQuestion> _multipleChoice(
    LearningPath path,
    CurriculumModule module,
    Concept concept,
  ) {
    final questions = <InterviewQuestion>[];
    for (final a in concept.assessments) {
      final index = a.correctOptionIndex;
      final options = a.options;
      if (a.type != ItemType.multipleChoice ||
          !_has(a.explanation) ||
          index == null ||
          options == null ||
          index >= options.length ||
          !a.prompt.trimRight().endsWith('?') ||
          _needsContext.hasMatch(a.prompt)) {
        continue;
      }
      // An explanation that compares the options makes no sense without
      // them; then the correct option has to be a full answer by itself.
      final answer = options[index];
      final standalone = !_leansOnQuiz.hasMatch(a.explanation!);
      if (_leansOnQuiz.hasMatch(answer)) continue;
      if (!standalone && answer.length < 80) continue;
      questions.add(
        _question(
          path,
          module,
          concept,
          id: a.id,
          prompt: a.prompt,
          modelAnswer: standalone ? '$answer\n\n${a.explanation}' : answer,
          label: 'Concept',
        ),
      );
    }
    return questions;
  }

  static bool _has(String? s) => s != null && s.trim().isNotEmpty;

  static String _fence(String code) => '```\n${code.trimRight()}\n```';

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
