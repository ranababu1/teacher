import 'models/code_run.dart';

/// Pluggable code execution backend. Implementations must run code in a
/// sandbox outside the app (instructions.md section 33).
abstract class CodeRunner {
  Future<CodeRunResult> run(CodeRunRequest request);
}

/// Validates a code runner URL typed by the learner. Only absolute https
/// URLs with a host are accepted; anything else returns null.
Uri? parseCodeRunnerUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.isAbsolute || uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri;
}
