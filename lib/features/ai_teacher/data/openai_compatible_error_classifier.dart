/// Turns a failed OpenAI-compatible (OpenAI, DeepSeek) HTTP response into a
/// specific, plain-language message a non-technical learner can act on —
/// never the raw server error text. See instructions.md section 37
/// (actionable, human messages) and section 38 (never expose raw server
/// detail to the UI).
///
/// The OpenAI Chat Completions error body has a canonical `error.code`/
/// `error.type` string that is more reliable than guessing from the bare
/// HTTP status code alone, so that's checked first; the HTTP status code
/// is only a fallback for responses that don't follow the usual shape.
String classifyOpenAiCompatibleError({
  required int? statusCode,
  required dynamic responseBody,
  required String providerLabel,
}) {
  final error = _asMap(responseBody)?['error'];
  final errorMap = _asMap(error);
  final errorCode = (errorMap?['code'] as String?) ?? '';
  final errorType = (errorMap?['type'] as String?) ?? '';

  if (errorCode == 'invalid_api_key' || errorType == 'authentication_error') {
    return "Your $providerLabel API key isn't working. Check it in Settings.";
  }
  if (errorCode == 'insufficient_quota' || errorType == 'insufficient_quota') {
    return "You've reached $providerLabel's usage limit for now. Wait a bit and try again.";
  }

  switch (statusCode) {
    case 401:
      return "Your $providerLabel API key isn't working. Check it in Settings.";
    case 403:
      return "Your $providerLabel API key doesn't have permission for this. Check it in Settings.";
    case 429:
      return "You've reached $providerLabel's usage limit for now. Wait a bit and try again.";
    case 500:
    case 502:
    case 503:
    case 504:
      return '$providerLabel\'s AI service is temporarily busy. Try again in a moment.';
    default:
      return "The AI teacher isn't available right now. Try again shortly.";
  }
}

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;
