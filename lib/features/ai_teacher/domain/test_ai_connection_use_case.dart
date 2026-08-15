import '../../../core/services/app_logger.dart';
import 'ai_provider.dart';

/// Backs Settings' "Test AI Connection" action — a thin wrapper so the UI
/// never calls [AIProvider] directly (see instructions.md section 19).
class TestAiConnectionUseCase {
  TestAiConnectionUseCase({
    required AIProvider aiProvider,
    this.requestLoggingEnabled = false,
  }) : _aiProvider = aiProvider;

  final AIProvider _aiProvider;
  final bool requestLoggingEnabled;

  Future<void> call() async {
    if (requestLoggingEnabled) {
      AppLogger.debug('AI test-connection request');
    }
    await _aiProvider.testConnection();
  }
}
