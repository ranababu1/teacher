import 'models/code_run.dart';

/// Configuration and access point for running learner code remotely.
///
/// Disabled by default: until the learner saves a runner URL in Settings,
/// [endpoint] is null and [run] throws a configuration error.
abstract class CodeRunnerRepository {
  Future<Uri?> endpoint();

  /// Saves [url] (validated, https only), or turns the runner off when
  /// [url] is null or blank. Throws [ArgumentError] for an invalid URL.
  Future<void> setEndpoint(String? url);

  Future<CodeRunResult> run(CodeRunRequest request);
}
