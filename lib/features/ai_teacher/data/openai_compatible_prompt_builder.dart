import '../../settings/domain/settings_models.dart';
import '../domain/models/module_test_context.dart';
import '../domain/models/teaching_context.dart';
import 'shared_prompt_builder.dart' as shared;

/// A ready-to-send prompt for an OpenAI-compatible chat model.
typedef OpenAiCompatiblePrompt =
    ({String systemInstruction, String userContent});

// Thin wrapper over the shared, provider-agnostic prompt builders in
// shared_prompt_builder.dart. Unlike Gemini/Anthropic, this provider's
// response_format: json_object mode only guarantees *valid JSON*, not a
// specific shape — so each output instruction below spells out the exact
// JSON shape in prose instead of relying on nativeSchemaOutputInstruction.

const _teachShapeInstruction =
    'Output requirement: respond with ONLY a raw JSON object of exactly '
    'this shape: {"explanation": "<string>", "followUpQuestion": '
    '"<string, omit this key entirely if there is no follow-up question>"}. '
    'No markdown code fences, no prose before or after it, nothing but the '
    'JSON object itself.';

const _assessShapeInstruction =
    'Output requirement: respond with ONLY a raw JSON object of exactly '
    'this shape: {"isCorrect": <boolean>, "feedback": "<string>", '
    '"detectedMisconceptions": ["<string>", ...]} — use an empty array if '
    'none were detected. No markdown code fences, no prose before or after '
    'it, nothing but the JSON object itself.';

const _generateExerciseShapeInstruction =
    'Output requirement: respond with ONLY a raw JSON object of exactly '
    'this shape: {"id": "<string, a short unique slug>", "type": '
    '"<one of: multipleChoice, shortAnswer, predictOutput, debugging, '
    'coding, explanation, scenario>", "prompt": "<string>", "hints": '
    '["<string>", ...], "code": "<string, omit if not applicable>", '
    '"expectedAnswer": "<string, omit if not applicable>", '
    '"solutionCode": "<string, omit if not applicable>", '
    '"solutionExplanation": "<string, omit if not applicable>", '
    '"difficultyLevel": <integer 1-7, omit if not applicable>}. The '
    '"type" value must be exactly one of the seven listed strings, spelled '
    'exactly as shown. No markdown code fences, no prose before or after '
    'it, nothing but the JSON object itself.';

const _evaluateExplanationShapeInstruction =
    'Output requirement: respond with ONLY a raw JSON object of exactly '
    'this shape: {"isCorrect": <boolean>, "isComplete": <boolean>, '
    '"feedback": "<string>", "detectedMisconceptions": ["<string>", ...]} '
    '— use an empty array if none were detected. No markdown code fences, '
    'no prose before or after it, nothing but the JSON object itself.';

String _moduleTestShapeInstruction(int questionCount) =>
    'Output requirement: respond with ONLY a raw JSON object of exactly '
    'this shape: {"questions": [{"id": "<string, a short unique slug>", '
    '"type": "multipleChoice", "prompt": "<string>", "options": '
    '["<string>", ...] (3-4 options), "correctOptionIndex": <integer>, '
    '"explanation": "<string, omit if not applicable>"}, ...]}. The '
    '"questions" array must contain exactly $questionCount items, and '
    'every "type" value must be exactly "multipleChoice". No markdown '
    'code fences, no prose before or after it, nothing but the JSON '
    'object itself.';

OpenAiCompatiblePrompt buildTeachPrompt(
  TeachingContext context,
  String? learnerMessage, {
  required ExplanationDepth depth,
}) => shared.buildTeachPrompt(
  context,
  learnerMessage,
  depth: depth,
  outputInstruction: _teachShapeInstruction,
);

OpenAiCompatiblePrompt buildAssessPrompt(
  TeachingContext context,
  String learnerResponse, {
  required ExplanationDepth depth,
}) => shared.buildAssessPrompt(
  context,
  learnerResponse,
  depth: depth,
  outputInstruction: _assessShapeInstruction,
);

OpenAiCompatiblePrompt buildGenerateExercisePrompt(
  TeachingContext context, {
  required ExplanationDepth depth,
}) => shared.buildGenerateExercisePrompt(
  context,
  depth: depth,
  outputInstruction: _generateExerciseShapeInstruction,
);

OpenAiCompatiblePrompt buildEvaluateExplanationPrompt(
  TeachingContext context,
  String learnerExplanation, {
  required ExplanationDepth depth,
}) => shared.buildEvaluateExplanationPrompt(
  context,
  learnerExplanation,
  depth: depth,
  outputInstruction: _evaluateExplanationShapeInstruction,
);

OpenAiCompatiblePrompt buildModuleTestPrompt(
  ModuleTestContext context, {
  required int questionCount,
  required ExplanationDepth depth,
}) => shared.buildModuleTestPrompt(
  context,
  questionCount: questionCount,
  depth: depth,
  outputInstruction: _moduleTestShapeInstruction(questionCount),
);
