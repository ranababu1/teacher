import '../../settings/domain/settings_models.dart';
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
