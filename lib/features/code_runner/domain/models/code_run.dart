/// One request to execute learner code in an external sandbox.
///
/// See instructions.md section 33: learner code never runs inside the
/// Flutter process.
class CodeRunRequest {
  const CodeRunRequest({
    required this.language,
    required this.source,
    this.stdin = '',
    this.timeoutSeconds = 10,
  });

  final String language;
  final String source;
  final String stdin;
  final int timeoutSeconds;

  Map<String, dynamic> toJson() => {
    'language': language,
    'source': source,
    'stdin': stdin,
    'timeoutSeconds': timeoutSeconds,
  };
}

/// What the sandbox reported back.
class CodeRunResult {
  const CodeRunResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    this.timedOut = false,
  });

  final String stdout;
  final String stderr;
  final int exitCode;
  final bool timedOut;

  bool get succeeded => exitCode == 0 && !timedOut;

  /// Parses the documented response shape. Throws [FormatException] when a
  /// required field is missing or has the wrong type.
  factory CodeRunResult.fromJson(Map<String, dynamic> json) {
    final exitCode = json['exitCode'];
    if (exitCode is! int) {
      throw const FormatException('exitCode must be an integer');
    }
    final stdout = json['stdout'] ?? '';
    final stderr = json['stderr'] ?? '';
    final timedOut = json['timedOut'] ?? false;
    if (stdout is! String || stderr is! String || timedOut is! bool) {
      throw const FormatException('stdout, stderr or timedOut has a bad type');
    }
    return CodeRunResult(
      stdout: stdout,
      stderr: stderr,
      exitCode: exitCode,
      timedOut: timedOut,
    );
  }
}
