import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/models/exercise.dart';

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
