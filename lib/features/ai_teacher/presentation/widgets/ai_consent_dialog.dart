import 'package:flutter/material.dart';

import '../../../settings/domain/settings_models.dart';

/// Who receives the data, named as the company rather than the product.
String _recipient(AiProviderKind provider) => switch (provider) {
  AiProviderKind.gemini => 'Google (Gemini)',
  AiProviderKind.openai => 'OpenAI',
  AiProviderKind.anthropic => 'Anthropic (Claude)',
  AiProviderKind.deepseek => 'DeepSeek',
};

/// One-time permission to send learner data to [provider]. Dismissing the
/// dialog counts as no.
Future<bool> showAiConsentDialog(
  BuildContext context,
  AiProviderKind provider,
) async {
  final allowed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AiConsentDialog(provider: provider),
  );
  return allowed ?? false;
}

class AiConsentDialog extends StatelessWidget {
  const AiConsentDialog({super.key, required this.provider});

  final AiProviderKind provider;

  /// Keep in step with `shared_prompt_builder.dart`, which decides what is
  /// actually sent.
  static const _sent = [
    'Questions, answers and explanations you write for the AI',
    'The lesson or topic you are working on',
    'Your progress: mastery scores, attempt counts, difficulty level, '
        'misconceptions and completed work',
    'For study plans and roadmaps: your goal, level, available time and '
        'planned steps',
    'Your API key, to authorize the request',
  ];

  @override
  Widget build(BuildContext context) {
    final recipient = _recipient(provider);
    return AlertDialog(
      scrollable: true,
      title: Text('Share data with $recipient?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI features send data from this device directly to '
            '$recipient. Depending on the feature, a request includes:',
          ),
          const SizedBox(height: 12),
          for (final item in _sent)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExcludeSemantics(child: Text('•  ')),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '$recipient handles this data under its own terms and privacy '
            'policy. Avoid including personal or confidential details. '
            'Allowing applies to later requests to this provider too.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Allow'),
        ),
      ],
    );
  }
}
