import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

/// A first-class code display widget: syntax highlighting, optional line
/// numbers, and a copy button. See instructions.md section 32.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.language = 'python',
    this.showLineNumbers = false,
    this.highlightLines = const {},
  });

  final String code;
  final String language;
  final bool showLineNumbers;

  /// 1-based line numbers to highlight (e.g. the buggy line in a debugging
  /// exercise).
  final Set<int> highlightLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F22) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(language: language, code: code),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLineNumbers) _LineNumbers(count: lines.length),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200),
                    child: HighlightView(
                      code,
                      language: language,
                      theme: isDark ? atomOneDarkTheme : atomOneLightTheme,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.language, required this.code});

  final String language;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      child: Row(
        children: [
          Text(
            language,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
          ),
          const Spacer(),
          _CopyButton(code: code),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});

  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check : Icons.copy_outlined,
        size: 16,
        color: _copied ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Copy code',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _LineNumbers extends StatelessWidget {
  const _LineNumbers({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          count,
          (i) => Text(
            '${i + 1}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.5,
              height: 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
