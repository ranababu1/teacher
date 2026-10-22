import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/code_runner.dart';
import '../providers/code_runner_providers.dart';

/// Settings entry for the optional remote code runner. Off by default.
class CodeRunnerSettingsTile extends ConsumerWidget {
  const CodeRunnerSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpoint = ref.watch(codeRunnerEndpointProvider);
    final subtitle = endpoint.when(
      data: (uri) => uri == null
          ? 'Off. Add the URL of your own sandboxed execution API to run '
                'challenge code.'
          : uri.toString(),
      loading: () => 'Loading...',
      error: (_, _) => "Couldn't load the runner setting.",
    );
    return ListTile(
      key: const ValueKey('code-runner-setting'),
      contentPadding: EdgeInsets.zero,
      title: const Text('Code runner (experimental)'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _edit(context, ref, endpoint.valueOrNull),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Uri? current) async {
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _CodeRunnerDialog(initial: current?.toString() ?? ''),
    );
    if (result == null) return;
    try {
      await ref
          .read(codeRunnerRepositoryProvider)
          .setEndpoint(result.clear ? null : result.url);
      ref.invalidate(codeRunnerEndpointProvider);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    }
  }
}

class _EditResult {
  const _EditResult({this.url, this.clear = false});

  final String? url;
  final bool clear;
}

class _CodeRunnerDialog extends StatefulWidget {
  const _CodeRunnerDialog({required this.initial});

  final String initial;

  @override
  State<_CodeRunnerDialog> createState() => _CodeRunnerDialogState();
}

class _CodeRunnerDialogState extends State<_CodeRunnerDialog> {
  late final TextEditingController _url = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _save() {
    if (parseCodeRunnerUrl(_url.text) == null) {
      setState(() => _error = 'Enter a full https:// URL');
      return;
    }
    Navigator.of(context).pop(_EditResult(url: _url.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Code runner URL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code is sent to this URL to run in a sandbox you control. '
            'Leave it off unless you run your own execution API.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('code-runner-url'),
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'https://...',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        if (widget.initial.isNotEmpty)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(const _EditResult(clear: true)),
            child: const Text('Turn off'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
