import '../../settings/domain/settings_models.dart';
import '../domain/models/module_test_context.dart';
import '../domain/models/roadmap_generation.dart';
import '../domain/models/study_coaching.dart';
import '../domain/models/teaching_context.dart';

/// A ready-to-send AI prompt: a system instruction (persona, teaching
/// principles, output-format rule) and the user content (the assembled
/// teaching context plus the specific ask).
typedef AiPrompt = ({String systemInstruction, String userContent});

/// Appended to the system instruction by any provider whose API enforces
/// the JSON shape out-of-band (Gemini's `responseSchema`, Anthropic's
/// `output_config.format`) — the wording names no provider, so it is
/// shared verbatim across all of them.
const nativeSchemaOutputInstruction =
    'Output requirement: respond with ONLY the raw JSON object matching '
    'the supplied response schema — no markdown code fences, no prose '
    'before or after it, nothing but the JSON object itself.';

/// Pure prompt construction for the "teach" capability — no I/O, safe to
/// unit test directly.
///
/// See instructions.md section 20 — "never send an isolated question to
/// the AI if context is available." Every builder in this file starts
/// from the same rich [TeachingContext] block before adding its specific
/// ask.
AiPrompt buildTeachPrompt(
  TeachingContext context,
  String? learnerMessage, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _teachAddendum,
    outputInstruction: outputInstruction,
  );
  final ask = (learnerMessage == null || learnerMessage.trim().isEmpty)
      ? 'The learner has not asked anything specific yet. Open or continue '
            'teaching this concept from wherever they currently are, given '
            'the mastery data above.'
      : 'The learner says: "$learnerMessage"\n\n'
            'Respond to them as their teacher, using the context above.';
  final user = '${_contextBlock(context)}\n## Task\n$ask';
  return (systemInstruction: system, userContent: user);
}

/// Pure prompt construction for the "assess" capability.
AiPrompt buildAssessPrompt(
  TeachingContext context,
  String learnerResponse, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _assessAddendum,
    outputInstruction: outputInstruction,
  );
  final user =
      '${_contextBlock(context)}\n## Task\n'
      'Assess the following learner response to a question about this '
      'concept, given everything above:\n"$learnerResponse"';
  return (systemInstruction: system, userContent: user);
}

/// Pure prompt construction for the "generate exercise" capability.
AiPrompt buildGenerateExercisePrompt(
  TeachingContext context, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _generateExerciseAddendum,
    outputInstruction: outputInstruction,
  );
  final user =
      '${_contextBlock(context)}\n## Task\n'
      'Generate one new exercise for this concept, calibrated to the '
      "learner's current difficulty level and mastery shown above.";
  return (systemInstruction: system, userContent: user);
}

/// Pure prompt construction for the "evaluate explanation" capability.
AiPrompt buildEvaluateExplanationPrompt(
  TeachingContext context,
  String learnerExplanation, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _evaluateExplanationAddendum,
    outputInstruction: outputInstruction,
  );
  final user =
      '${_contextBlock(context)}\n## Task\n'
      'Evaluate the following explanation the learner gave in their own '
      'words about this concept:\n"$learnerExplanation"';
  return (systemInstruction: system, userContent: user);
}

/// Pure prompt construction for the "module test" capability — a batch of
/// [questionCount] multiple-choice questions covering every concept in
/// [context], used to gate advancing to the next module in a path.
AiPrompt buildModuleTestPrompt(
  ModuleTestContext context, {
  required int questionCount,
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _moduleTestAddendum(questionCount),
    outputInstruction: outputInstruction,
  );

  final buffer = StringBuffer()
    ..writeln('## Topic: ${context.moduleTitle}')
    ..writeln(
      'This topic covers ${context.conceptContexts.length} concept'
      '${context.conceptContexts.length == 1 ? '' : 's'}, detailed below.',
    );
  for (final conceptContext in context.conceptContexts) {
    buffer
      ..writeln()
      ..write(_contextBlock(conceptContext));
  }
  buffer
    ..writeln()
    ..writeln('## Task')
    ..writeln(
      'Author exactly $questionCount multiple-choice questions that '
      'together test understanding of every concept described above. '
      'Spread the questions across the concepts rather than clustering '
      'them all on just one. Each question must have exactly one '
      'unambiguously correct option among 3-4 plausible options, and must '
      'not be a verbatim copy of any example already shown.',
    );

  return (systemInstruction: system, userContent: buffer.toString());
}

/// Pure prompt construction for the "study coach" capability: the app's
/// own plan plus a learner summary in, short advice out.
AiPrompt buildCoachStudyPlanPrompt(
  StudyCoachingRequest request, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _coachAddendum,
    outputInstruction: outputInstruction,
  );
  final buffer = StringBuffer()
    ..writeln('## Learner')
    ..writeln(request.learnerSummary.trim());
  final goal = request.careerGoal?.trim();
  if (goal != null && goal.isNotEmpty) {
    buffer.writeln('Career goal: $goal');
  }
  buffer
    ..writeln()
    ..writeln("## Today's plan (built by the app, in order)");
  for (final (i, step) in request.planSteps.indexed) {
    buffer.writeln('${i + 1}. $step');
  }
  buffer
    ..writeln()
    ..writeln('## Task')
    ..writeln(
      'Coach this learner on the plan above. Write a 2-3 sentence '
      'honest summary of where they stand, one concrete focus for the '
      'coming week tied to their goal when one is given, and exactly '
      '${request.planSteps.length} short tips (one per plan step, same '
      'order, at most 25 words each) on how to get the most out of that '
      'step. Do not add steps, reorder them, or mention content the plan '
      'does not include.',
    );
  return (systemInstruction: system, userContent: buffer.toString());
}

/// Pure prompt construction for the "personal roadmap" capability: the
/// learner's goal and the app's content catalog in, a week-by-week plan
/// out that uses only catalog ids.
AiPrompt buildGenerateRoadmapPrompt(
  RoadmapGenerationRequest request, {
  required ExplanationDepth depth,
  required String outputInstruction,
}) {
  final system = _systemInstruction(
    depth: depth,
    addendum: _roadmapAddendum,
    outputInstruction: outputInstruction,
  );
  final buffer = StringBuffer()
    ..writeln('## Learner')
    ..writeln('Goal: ${request.goal.trim()}')
    ..writeln('Current level: ${request.level}')
    ..writeln('Time available: ${request.hoursPerWeek} hours per week')
    ..writeln('Plan length: ${request.weeks} weeks');
  final summary = request.learnerSummary.trim();
  if (summary.isNotEmpty) buffer.writeln(summary);
  buffer
    ..writeln()
    ..writeln('## Catalog (the only content you may use)')
    ..writeln(request.catalog.trim())
    ..writeln()
    ..writeln('## Task')
    ..writeln(
      'Build a ${request.weeks}-week roadmap toward the goal. Return '
      'exactly ${request.weeks} weeks in order. Each week has a short '
      'focus (at most 8 words) and items whose total hours roughly fit '
      '${request.hoursPerWeek} hours. Every item must use a kind and an id '
      'copied exactly from the catalog ("topic" ids look like '
      '"course/topic"). Never invent ids, courses or resources outside the '
      'catalog. Order topics within a course as listed, skip what the '
      'level or progress says they already know, and add a project, a '
      'coding challenge or a system design exercise once the topics it '
      'builds on are covered. Give each item a note of at most 20 words '
      'on why it matters for the goal, and a 2-3 sentence summary of the '
      'plan.',
    );
  return (systemInstruction: system, userContent: buffer.toString());
}

const _roadmapAddendum =
    'For this request you are acting as a curriculum planner, not '
    'explaining a concept. Be realistic about time, prefer depth in a few '
    'relevant courses over a little of everything, and only use content '
    'from the catalog provided.';

const _coachAddendum =
    'For this request you are acting as a study coach, not explaining a '
    'concept. Be specific and practical, refer to the actual topics named, '
    'and never pad with generic motivation.';

// ---------------------------------------------------------------------------
// System instruction — shared core + capability-specific addendum.
// ---------------------------------------------------------------------------

String _systemInstruction({
  required ExplanationDepth depth,
  required String addendum,
  required String outputInstruction,
}) {
  final buffer = StringBuffer()
    ..writeln(
      'You are the AI teacher inside a deep-learning app for software '
      'engineering topics. Behave like a precise, senior engineer who is '
      'also an excellent teacher — never like a generic chatbot.',
    )
    ..writeln(
      'Be precise and explain deeply. Avoid unnecessary jargon, and ground '
      'abstract ideas in practical, realistic examples rather than '
      'contrived toy ones. Prefer building the reasoning over demanding '
      'memorized facts.',
    )
    ..writeln(
      "Ask at most one meaningful, focused question at a time when it's "
      'useful to check or advance understanding. When the learner is '
      'working through a problem, never hand them the complete answer '
      'immediately — give progressively stronger hints instead and let '
      'them do the reasoning.',
    )
    ..writeln(
      'When reasoning is incorrect, challenge it directly and name the '
      'misconception explicitly — do not gloss over it, soften it into '
      'vagueness, or offer encouragement that is not earned. Never pretend '
      'the learner understands something they have not demonstrated.',
    )
    ..writeln(
      "Calibrate to the learner: use the mastery scores and current "
      "difficulty level given in the context below so you neither re-teach "
      "what they have already mastered nor skip ahead of what they "
      "haven't.",
    )
    ..writeln(_depthInstruction(depth))
    ..writeln(addendum)
    ..writeln(outputInstruction);
  return buffer.toString();
}

String _depthInstruction(ExplanationDepth depth) {
  switch (depth) {
    case ExplanationDepth.concise:
      return 'Verbosity: concise. Be short and to the point, with minimal '
          'preamble — get to the substance immediately.';
    case ExplanationDepth.standard:
      return 'Verbosity: standard. Give a balanced explanation together '
          'with one well-chosen example.';
    case ExplanationDepth.deep:
      return 'Verbosity: deep. Be thorough — cover the idea from multiple '
          'angles, call out edge cases, and connect it explicitly to '
          'related concepts.';
  }
}

const _teachAddendum =
    'Right now: teach or continue teaching the concept described below, '
    'responding to whatever the learner just said (or opening the topic '
    "if they haven't said anything yet). End with a single focused "
    'follow-up question when doing so would move their understanding '
    'forward; otherwise leave the follow-up question out.';

const _assessAddendum =
    "Right now: grade the learner's response to a question about the "
    'concept described below. Decide whether it is correct, give direct '
    'feedback that praises only what is actually earned, and explicitly '
    'name any misconceptions you detect.';

const _generateExerciseAddendum =
    'Right now: author exactly one new practice exercise for the concept '
    "described below, calibrated to the learner's current difficulty level "
    'and mastery. It must not be a verbatim copy of any example already '
    'shown.';

const _evaluateExplanationAddendum =
    "Right now: evaluate the learner's own explanation, in their own "
    'words, of the concept described below. Judge correctness and '
    'completeness as two separate questions, and explicitly name any '
    'misconceptions revealed in their explanation.';

String _moduleTestAddendum(int questionCount) =>
    'Right now: you are authoring a gating test for an entire topic '
    '(module) of $questionCount multiple-choice questions, not teaching '
    'or responding to a single learner message.';

// ---------------------------------------------------------------------------
// Shared context block.
// ---------------------------------------------------------------------------

String _contextBlock(TeachingContext context) {
  final concept = context.concept;
  final mastery = context.mastery;
  final buffer = StringBuffer();

  buffer
    ..writeln('## Concept')
    ..writeln('Title: ${concept.title}')
    ..writeln('Description: ${concept.description}')
    ..writeln('Difficulty: ${concept.difficulty.label}')
    ..writeln('Estimated time: ${concept.estimatedMinutes} minutes');

  if (concept.learningObjectives.isNotEmpty) {
    buffer.writeln('Learning objectives:');
    for (final objective in concept.learningObjectives) {
      buffer.writeln('- $objective');
    }
  }

  if (concept.explanation.sections.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        '## Reference explanation (curriculum-authored, for your context '
        'only — do not just repeat it verbatim)',
      );
    for (final section in concept.explanation.sections) {
      buffer
        ..writeln('### ${section.heading}')
        ..writeln(section.body);
    }
  }

  if (concept.examples.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Existing examples already shown to the learner');
    for (final example in concept.examples) {
      buffer.writeln(
        '- ${example.title} (${example.language}): ${example.explanation}',
      );
    }
  }

  if (context.prerequisites.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Prerequisites the learner should already know');
    for (final prerequisite in context.prerequisites) {
      buffer.writeln('- ${prerequisite.title}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Learner mastery of this concept')
    ..writeln('Status: ${mastery.status.label}')
    ..writeln('Overall mastery: ${mastery.overallMastery.toStringAsFixed(2)}')
    ..writeln('Recall score: ${mastery.recallScore.toStringAsFixed(2)}')
    ..writeln(
      'Understanding score: ${mastery.understandingScore.toStringAsFixed(2)}',
    )
    ..writeln(
      'Application score: ${mastery.applicationScore.toStringAsFixed(2)}',
    )
    ..writeln(
      'Explanation score: ${mastery.explanationScore.toStringAsFixed(2)}',
    )
    ..writeln('Coding score: ${mastery.codingScore.toStringAsFixed(2)}')
    ..writeln('Debugging score: ${mastery.debuggingScore.toStringAsFixed(2)}')
    ..writeln('Attempts so far: ${mastery.attemptCount}')
    ..writeln(
      'Current difficulty level (1-7 ladder): '
      '${context.currentDifficultyLevel}',
    );

  if (context.recentMisconceptions.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Misconceptions recently observed for this learner');
    for (final misconception in context.recentMisconceptions) {
      buffer.writeln('- $misconception');
    }
  }

  return buffer.toString();
}
