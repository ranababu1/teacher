import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/code_run.dart';
import '../providers/code_runner_providers.dart';

/// "Run code" affordance for a code editor. Renders nothing unless the
/// learner has configured a code runner URL in Settings.
class RunCodePanel extends ConsumerStatefulWidget {
  const RunCodePanel({super.key, required this.language, required this.source});

  final String language;

  /// Reads the current editor contents at the moment Run is pressed.
  final String Function() source;

  @override
  ConsumerState<RunCodePanel> createState() => _RunCodePanelState();
}

class _RunCodePanelState extends ConsumerState<RunCodePanel> {
  bool _running = false;
  CodeRunResult? _result;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref
          .read(codeRunnerRepositoryProvider)
          .run(
            CodeRunRequest(language: widget.language, source: widget.source()),
          );
      if (mounted) setState(() => _result = result);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final endpoint = ref.watch(codeRunnerEndpointProvider).valueOrNull;
    if (endpoint == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final result = _result;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('run-code'),
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_running ? 'Running...' : 'Run code'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (result != null)
            Container(
              key: const ValueKey('run-output'),
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _describe(result),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _describe(CodeRunResult r) {
    final status = r.timedOut
        ? 'Timed out'
        : r.exitCode == 0
        ? 'Exited with code 0'
        : 'Exited with code ${r.exitCode}';
    final out = r.stdout.isEmpty && r.stderr.isEmpty
        ? '(no output)'
        : [r.stdout, r.stderr].where((s) => s.isNotEmpty).join('\n');
    return '$status\n$out';
  }
}
