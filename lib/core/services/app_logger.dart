import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Structured logging for the app.
///
/// Never pass API keys, full AI prompts containing private information, or
/// other credentials to these methods — see instructions.md section 38.
///
/// Release builds are quiet by design: [debug] and [info] sit below the
/// WARNING threshold and are dropped, and warnings/errors print as plain
/// single lines instead of boxed PrettyPrinter output. This is also what
/// makes the opt-in "AI request logging" setting effectively dead in the
/// wild — that output goes through [debug].
class AppLogger {
  AppLogger._();

  static final Logger _logger = kReleaseMode
      ? Logger(
          // Plain one-liners without ANSI colors: friendlier to logcat and
          // to whatever shell Play pre-launch report testing uses.
          printer: SimplePrinter(colors: false),
          // Warnings and errors only — no debug/info chatter in production.
          level: Level.warning,
        )
      : Logger(
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
