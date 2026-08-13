import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_teacher/presentation/providers/api_key_providers.dart';

/// Lets the learner enter their own Gemini API key, stored via the
/// platform's secure storage — never bundled with the app. See
/// instructions.md section 27 and features/ai_teacher/data/secure_api_key_store.dart.
class ApiKeySection extends ConsumerStatefulWidget {
  const ApiKeySection({super.key});

  @override
  ConsumerState<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<ApiKeySection> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) return;
    await ref.read(geminiApiKeyControllerProvider.notifier).save(apiKey);
    _controller.clear();
    setState(() => _editing = false);
  }

  Future<void> _clear() async {
    await ref.read(geminiApiKeyControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyValue = ref.watch(geminiApiKeyControllerProvider);
    final hasKey = keyValue.valueOrNull?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            hasKey ? Icons.smart_toy : Icons.smart_toy_outlined,
            color: hasKey
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: const Text('Gemini API key'),
          subtitle: Text(
            keyValue.isLoading
                ? 'Checking...'
                : hasKey
                ? 'Configured — stored securely on this device, never uploaded anywhere '
                      'except directly to Gemini.'
                : "Not configured. Add your own key below — it's stored using this "
                      'device\'s hardware-backed keystore, not bundled with the app.',
          ),
        ),
        if (hasKey && !_editing)
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => setState(() => _editing = true),
                  child: const Text('Change'),
                ),
                TextButton(onPressed: _clear, child: const Text('Remove')),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Paste your Gemini API key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_editing)
                      TextButton(
                        onPressed: () => setState(() => _editing = false),
                        child: const Text('Cancel'),
                      ),
                    FilledButton(onPressed: _save, child: const Text('Save')),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
