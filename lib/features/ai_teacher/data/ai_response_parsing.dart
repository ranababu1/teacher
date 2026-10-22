import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/exercise.dart';
import '../domain/models/roadmap_generation.dart';

/// Strict field extraction shared by every AIProvider implementation —
/// throws [InvalidAIResponseException] (rather than letting a raw
/// TypeError/CastError escape) on a missing or wrong-typed key, so
/// [callWithRetry] can catch it uniformly regardless of which provider
/// produced the response.

String reqString(
  Map<String, dynamic> json,
  String key, {
  required String providerLabel,
}) {
  final value = json[key];
  if (value is! String) {
    throw InvalidAIResponseException(
      '$providerLabel response missing required string field "$key"',
    );
  }
  return value;
}

String? optString(
  Map<String, dynamic> json,
  String key, {
  required String providerLabel,
}) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String) {
    throw InvalidAIResponseException(
      '$providerLabel response has a non-string value for field "$key"',
    );
  }
  return value;
}

bool reqBool(
  Map<String, dynamic> json,
  String key, {
  required String providerLabel,
}) {
  final value = json[key];
  if (value is! bool) {
    throw InvalidAIResponseException(
      '$providerLabel response missing required boolean field "$key"',
    );
  }
  return value;
}

List<String> reqStringList(
  Map<String, dynamic> json,
  String key, {
  required String providerLabel,
}) {
  final value = json[key];
  if (value is! List) {
    throw InvalidAIResponseException(
      '$providerLabel response missing required array field "$key"',
    );
  }
  return value.map((entry) {
    if (entry is! String) {
      throw InvalidAIResponseException(
        '$providerLabel response has a non-string entry in array field "$key"',
      );
    }
    return entry;
  }).toList();
}

Exercise parseExercise(
  Map<String, dynamic> json, {
  required String providerLabel,
}) {
  try {
    return Exercise.fromJson(json);
  } on InvalidAIResponseException {
    rethrow;
  } catch (e) {
    throw InvalidAIResponseException(
      'Could not parse exercise from $providerLabel response: $e',
    );
  }
}

/// Parses `{"questions": [...]}` into a list of [Assessment]s, throwing
/// [InvalidAIResponseException] on a malformed entry or a list shorter
/// than [minCount] — either way plugging into the existing
/// [callWithRetry] the same as every other parse helper here.
List<Assessment> parseAssessmentList(
  Map<String, dynamic> json, {
  required String providerLabel,
  required int minCount,
}) {
  final value = json['questions'];
  if (value is! List) {
    throw InvalidAIResponseException(
      '$providerLabel response missing required array field "questions"',
    );
  }

  final assessments = <Assessment>[];
  for (final entry in value) {
    if (entry is! Map<String, dynamic>) {
      throw InvalidAIResponseException(
        '$providerLabel response has a non-object entry in "questions"',
      );
    }
    try {
      assessments.add(Assessment.fromJson(entry));
    } catch (e) {
      throw InvalidAIResponseException(
        'Could not parse a question from $providerLabel response: $e',
      );
    }
  }

  if (assessments.length < minCount) {
    throw InvalidAIResponseException(
      '$providerLabel response returned only ${assessments.length} '
      'questions, need at least $minCount',
    );
  }
  return assessments;
}

/// Runs [attempt] (a full generate-and-parse round trip); if it fails
/// because the response couldn't be parsed into the expected shape, runs
/// it exactly one more time. A second failure propagates as-is.
Future<T> callWithRetry<T>(Future<T> Function() attempt) async {
  try {
    return await attempt();
  } on InvalidAIResponseException {
    return await attempt();
  }
}

/// Parses `{"summary": ..., "weeks": [{"focus": ..., "items": [{"kind",
/// "id", "note"}]}]}`. Shape errors throw [InvalidAIResponseException];
/// whether ids are real is checked later against the app's catalog.
RoadmapDraft parseRoadmapDraft(
  Map<String, dynamic> json, {
  required String providerLabel,
}) {
  final weeksRaw = json['weeks'];
  if (weeksRaw is! List) {
    throw InvalidAIResponseException(
      '$providerLabel response missing required array field "weeks"',
    );
  }
  final weeks = <RoadmapDraftWeek>[];
  for (final w in weeksRaw) {
    if (w is! Map<String, dynamic>) {
      throw InvalidAIResponseException(
        '$providerLabel response has a non-object week',
      );
    }
    final itemsRaw = w['items'];
    if (itemsRaw is! List) {
      throw InvalidAIResponseException(
        '$providerLabel response week missing array field "items"',
      );
    }
    weeks.add(
      RoadmapDraftWeek(
        focus: optString(w, 'focus', providerLabel: providerLabel) ?? '',
        items: [
          for (final i in itemsRaw)
            if (i is Map<String, dynamic>)
              RoadmapDraftItem(
                kind: reqString(i, 'kind', providerLabel: providerLabel),
                id: reqString(i, 'id', providerLabel: providerLabel),
                note: optString(i, 'note', providerLabel: providerLabel) ?? '',
              ),
        ],
      ),
    );
  }
  return RoadmapDraft(
    summary: optString(json, 'summary', providerLabel: providerLabel) ?? '',
    weeks: weeks,
  );
}
