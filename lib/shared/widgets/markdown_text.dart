import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Renders authored lesson prose (bold/italic/inline code/fenced examples)
/// with styling that matches the app theme, instead of raw markdown syntax.
class MarkdownText extends StatelessWidget {
  const MarkdownText({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge,
        strong: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        em: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13.5,
          backgroundColor: colorScheme.surfaceContainerHigh,
          color: colorScheme.onSurface,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockSpacing: 12,
      ),
    );
  }
}
