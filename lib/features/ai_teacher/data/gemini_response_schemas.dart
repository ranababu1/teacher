/// Gemini `responseSchema` definitions — the structured-output dialect
/// Gemini accepts (a constrained subset of OpenAPI 3.0 schema objects).
///
/// One constant per [AIProvider] method response shape. These are passed
/// straight through to [GeminiApiClient.generateContent] so Gemini's
/// `generationConfig.responseMimeType: application/json` mode is forced to
/// emit exactly this shape — see [GeminiProvider] for the parsing side.
library;

/// Shape of [TeacherResponse].
const Map<String, dynamic> teacherResponseSchema = {
  'type': 'OBJECT',
  'properties': {
    'explanation': {'type': 'STRING'},
    'followUpQuestion': {'type': 'STRING', 'nullable': true},
  },
  'required': ['explanation'],
};

/// Shape of [AssessmentResult].
const Map<String, dynamic> assessmentResultSchema = {
  'type': 'OBJECT',
  'properties': {
    'isCorrect': {'type': 'BOOLEAN'},
    'feedback': {'type': 'STRING'},
    'detectedMisconceptions': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
  },
  'required': ['isCorrect', 'feedback', 'detectedMisconceptions'],
};

/// Shape matching `Exercise.fromJson` — see
/// lib/features/curriculum/domain/models/exercise.dart and item_type.dart
/// for the exact keys and the seven [ItemType] enum names.
const Map<String, dynamic> exerciseSchema = {
  'type': 'OBJECT',
  'properties': {
    'id': {'type': 'STRING'},
    'type': {
      'type': 'STRING',
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
    'prompt': {'type': 'STRING'},
    'hints': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
    'code': {'type': 'STRING', 'nullable': true},
    'expectedAnswer': {'type': 'STRING', 'nullable': true},
    'solutionCode': {'type': 'STRING', 'nullable': true},
    'solutionExplanation': {'type': 'STRING', 'nullable': true},
    'difficultyLevel': {'type': 'INTEGER', 'nullable': true},
  },
  'required': ['id', 'type', 'prompt', 'hints'],
};

/// Shape of [ExplanationEvaluation].
const Map<String, dynamic> explanationEvaluationSchema = {
  'type': 'OBJECT',
  'properties': {
    'isCorrect': {'type': 'BOOLEAN'},
    'isComplete': {'type': 'BOOLEAN'},
    'feedback': {'type': 'STRING'},
    'detectedMisconceptions': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
  },
  'required': ['isCorrect', 'isComplete', 'feedback', 'detectedMisconceptions'],
};

/// Shape matching a list of [Assessment]s, always `multipleChoice` — see
/// lib/features/curriculum/domain/models/assessment.dart for the exact
/// keys. Used for the module ("topic") gating test.
const Map<String, dynamic> moduleTestSchema = {
  'type': 'OBJECT',
  'properties': {
    'questions': {
      'type': 'ARRAY',
      'items': {
        'type': 'OBJECT',
        'properties': {
          'id': {'type': 'STRING'},
          'type': {
            'type': 'STRING',
            'enum': ['multipleChoice'],
          },
          'prompt': {'type': 'STRING'},
          'options': {
            'type': 'ARRAY',
            'items': {'type': 'STRING'},
          },
          'correctOptionIndex': {'type': 'INTEGER'},
          'explanation': {'type': 'STRING', 'nullable': true},
        },
        'required': ['id', 'type', 'prompt', 'options', 'correctOptionIndex'],
      },
    },
  },
  'required': ['questions'],
};
