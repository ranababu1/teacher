/// Base type for all application-level failures.
///
/// [message] is the technical detail (safe for logs). [userMessage] is
/// what gets shown in the UI and must always be human-readable and
/// actionable — never a stack trace or raw exception text.
sealed class AppException implements Exception {
  const AppException(this.message, this.userMessage);

  final String message;
  final String userMessage;

  @override
  String toString() => 'AppException: $message';
}

class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException([String message = 'No network connection'])
    : super(
        message,
        "You're offline. This feature needs an internet connection.",
      );
}

class AIUnavailableException extends AppException {
  const AIUnavailableException([String message = 'AI provider unavailable'])
    : super(
        message,
        "The AI teacher isn't available right now. You can keep learning — "
        'AI features will resume once the connection is restored.',
      );
}

class InvalidAIResponseException extends AppException {
  const InvalidAIResponseException([
    String message = 'AI response could not be parsed',
  ]) : super(
         message,
         'The AI teacher gave an unexpected response. Please try again.',
       );
}

class LocalDatabaseException extends AppException {
  const LocalDatabaseException([String message = 'Local database error'])
    : super(
        message,
        'Something went wrong saving your progress. Please try again.',
      );
}

class ContentNotFoundException extends AppException {
  const ContentNotFoundException([String message = 'Content not found'])
    : super(
        message,
        "We couldn't find that content. It may have moved or been removed.",
      );
}

class ConfigurationException extends AppException {
  const ConfigurationException([String message = 'Invalid configuration'])
    : super(
        message,
        'The app is missing required configuration. Check Settings.',
      );
}
