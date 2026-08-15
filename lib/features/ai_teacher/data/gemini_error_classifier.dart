/// Turns a failed Gemini HTTP response into a specific, plain-language
/// message a non-technical learner can act on — never the raw server
/// error text. See instructions.md section 37 (actionable, human
/// messages) and section 38 (never expose raw server detail to the UI).
///
/// Gemini's error body has a canonical `error.status` string (e.g.
/// `"UNAUTHENTICATED"`, `"RESOURCE_EXHAUSTED"`) that is far more reliable
/// than guessing from the bare HTTP status code alone, so that's checked
/// first; the HTTP status code is only a fallback for responses that
/// don't follow the usual shape.
String classifyGeminiError({required int? statusCode, required dynamic responseBody}) {
  final error = _asMap(responseBody)?['error'];
  final errorMap = _asMap(error);
  final errorStatus = errorMap?['status'] as String?;
  final errorMessage = (errorMap?['message'] as String?)?.toLowerCase() ?? '';

  // The API key itself being wrong most often surfaces as a 400
  // INVALID_ARGUMENT with "API key not valid" in the message, not a 401 —
  // catch that specific phrasing before falling back to status codes.
  if (errorMessage.contains('api key')) {
    return "Your Gemini API key isn't working. Check it in Settings.";
  }

  switch (errorStatus) {
    case 'UNAUTHENTICATED':
      return "Your Gemini API key isn't working. Check it in Settings.";
    case 'PERMISSION_DENIED':
      return "Your Gemini API key doesn't have permission for this. Check it in Settings.";
    case 'RESOURCE_EXHAUSTED':
      return "You've reached Gemini's usage limit for now. Wait a bit and try again.";
    case 'UNAVAILABLE':
    case 'DEADLINE_EXCEEDED':
      return 'Google\'s AI service is temporarily busy. Try again in a moment.';
    case 'NOT_FOUND':
      return "The AI teacher's setup looks misconfigured. Please report this.";
  }

  switch (statusCode) {
    case 401:
      return "Your Gemini API key isn't working. Check it in Settings.";
    case 403:
      return "Your Gemini API key doesn't have permission for this. Check it in Settings.";
    case 429:
      return "You've reached Gemini's usage limit for now. Wait a bit and try again.";
    case 500:
    case 502:
    case 503:
    case 504:
      return 'Google\'s AI service is temporarily busy. Try again in a moment.';
    default:
      return "The AI teacher isn't available right now. Try again shortly.";
  }
}

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;
