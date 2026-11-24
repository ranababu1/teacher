import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../settings/domain/settings_models.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../widgets/ai_consent_dialog.dart';

/// Asks the learner to allow sharing data with an [AiProviderKind].
typedef AiConsentPrompt = Future<bool> Function(AiProviderKind provider);

/// Shows the dialog above whatever screen triggered the request. With no
/// navigator to show it on, the answer is no: never send without asking.
final aiConsentPromptProvider = Provider<AiConsentPrompt>((ref) {
  return (provider) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    return showAiConsentDialog(context, provider);
  };
});

/// Remembers who the learner has agreed to share with. Kept apart from
/// `aiProviderProvider`, which rebuilds on every settings change and so
/// would lose the in-flight prompt.
class AiConsentService {
  AiConsentService(this._ref);

  final Ref _ref;
  final _pending = <AiProviderKind, Future<bool>>{};

  /// Simultaneous requests share one dialog. A "no" is not stored, so the
  /// next request asks again.
  Future<bool> ensure(AiProviderKind provider) =>
      _pending[provider] ??= _ask(provider).whenComplete(() {
        _pending.remove(provider);
      });

  Future<bool> _ask(AiProviderKind provider) async {
    final settings = await _ref.read(settingsControllerProvider.future);
    if (settings.aiConsentProviders.contains(provider)) return true;
    if (!await _ref.read(aiConsentPromptProvider)(provider)) return false;
    await _ref
        .read(settingsControllerProvider.notifier)
        .grantAiConsent(provider);
    return true;
  }
}

final aiConsentServiceProvider = Provider<AiConsentService>(
  AiConsentService.new,
);
