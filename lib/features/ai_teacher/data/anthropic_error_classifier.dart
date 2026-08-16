/// Turns a failed Anthropic Messages API response into a specific,
/// plain-language message a non-technical learner can act on — never the
/// raw server error text. See instructions.md section 37 (actionable,
/// human messages) and section 38 (never expose raw server detail to the
/// UI).
///
/// Anthropic's error body has a canonical `error.type` string (e.g.
/// `"authentication_error"`, `"rate_limit_error"`) that is more reliable
/// than guessing from the bare HTTP status code alone, so that's checked
/// first; the HTTP status code is only a fallback for responses that
/// don't follow the usual shape.
String classifyAnthropicError({
  required int? statusCode,
  required dynamic responseBody,
}) {
  final error = _asMap(responseBody)?['error'];
  final errorMap = _asMap(error);
  final errorType = errorMap?['type'] as String?;

  switch (errorType) {
    case 'authentication_error':
      return "Your Claude API key isn't working. Check it in Settings.";
    case 'permission_error':
      return "Your Claude API key doesn't have permission for this. Check it in Settings.";
    case 'rate_limit_error':
      return "You've reached Claude's usage limit for now. Wait a bit and try again.";
    case 'api_error':
    case 'overloaded_error':
      return 'Anthropic\'s AI service is temporarily busy. Try again in a moment.';
    case 'not_found_error':
      return "The AI teacher's setup looks misconfigured. Please report this.";
  }

  switch (statusCode) {
    case 401:
      return "Your Claude API key isn't working. Check it in Settings.";
    case 403:
      return "Your Claude API key doesn't have permission for this. Check it in Settings.";
    case 429:
      return "You've reached Claude's usage limit for now. Wait a bit and try again.";
    case 500:
    case 529:
      return 'Anthropic\'s AI service is temporarily busy. Try again in a moment.';
    default:
      return "The AI teacher isn't available right now. Try again shortly.";
  }
}

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;
