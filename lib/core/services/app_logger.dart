import 'package:logger/logger.dart';

/// Structured logging for the app.
///
/// Never pass API keys, full AI prompts containing private information, or
/// other credentials to these methods — see instructions.md section 38.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
