/// Anthropic `output_config.format.json_schema` definitions — standard
/// JSON Schema, unlike Gemini's constrained OpenAPI-3.0 subset. There is
/// no `nullable` keyword; optional fields use a `["<type>", "null"]` type
/// array instead, and strict mode requires every property (even nullable
/// ones) to be listed in `required`, with `additionalProperties: false`
/// on every object.
///
/// One constant per AIProvider method response shape. These are passed
/// straight through to [AnthropicApiClient.createMessage] — see
/// [AnthropicProvider] for the parsing side.
library;

/// Shape of [TeacherResponse].
const Map<String, dynamic> teacherResponseSchema = {
  'type': 'object',
  'properties': {
    'explanation': {'type': 'string'},
    'followUpQuestion': {
      'type': ['string', 'null'],
    },
  },
  'required': ['explanation', 'followUpQuestion'],
  'additionalProperties': false,
};

/// Shape of [AssessmentResult].
const Map<String, dynamic> assessmentResultSchema = {
  'type': 'object',
  'properties': {
    'isCorrect': {'type': 'boolean'},
    'feedback': {'type': 'string'},
    'detectedMisconceptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
  'required': ['isCorrect', 'feedback', 'detectedMisconceptions'],
  'additionalProperties': false,
};

/// Shape matching `Exercise.fromJson` — see
/// lib/features/curriculum/domain/models/exercise.dart and item_type.dart
/// for the exact keys and the seven ItemType enum names.
const Map<String, dynamic> exerciseSchema = {
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'type': {
      'type': 'string',
      'enum': [
        'multipleChoice',
        'shortAnswer',
        'predictOutput',
        'debugging',
        'coding',
        'explanation',
        'scenario',
      ],
    },
    'prompt': {'type': 'string'},
    'hints': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'code': {
      'type': ['string', 'null'],
    },
    'expectedAnswer': {
      'type': ['string', 'null'],
    },
    'solutionCode': {
      'type': ['string', 'null'],
    },
    'solutionExplanation': {
      'type': ['string', 'null'],
    },
    'difficultyLevel': {
      'type': ['integer', 'null'],
    },
  },
  'required': [
    'id',
    'type',
    'prompt',
    'hints',
    'code',
    'expectedAnswer',
    'solutionCode',
    'solutionExplanation',
    'difficultyLevel',
  ],
  'additionalProperties': false,
};

/// Shape of [ExplanationEvaluation].
const Map<String, dynamic> explanationEvaluationSchema = {
  'type': 'object',
  'properties': {
    'isCorrect': {'type': 'boolean'},
    'isComplete': {'type': 'boolean'},
    'feedback': {'type': 'string'},
    'detectedMisconceptions': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
  'required': ['isCorrect', 'isComplete', 'feedback', 'detectedMisconceptions'],
  'additionalProperties': false,
};

/// Shape matching a list of [Assessment]s, always `multipleChoice` — see
/// lib/features/curriculum/domain/models/assessment.dart for the exact
/// keys. Used for the module ("topic") gating test.
const Map<String, dynamic> moduleTestSchema = {
  'type': 'object',
  'properties': {
    'questions': {
      'type': 'array',
      'items': {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'type': {
            'type': 'string',
            'enum': ['multipleChoice'],
          },
          'prompt': {'type': 'string'},
          'options': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'correctOptionIndex': {'type': 'integer'},
          'explanation': {
            'type': ['string', 'null'],
          },
        },
        'required': [
          'id',
          'type',
          'prompt',
          'options',
          'correctOptionIndex',
          'explanation',
        ],
        'additionalProperties': false,
      },
    },
  },
  'required': ['questions'],
  'additionalProperties': false,
};
