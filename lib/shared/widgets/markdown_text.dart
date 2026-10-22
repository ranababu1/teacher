import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Renders authored lesson prose (bold/italic/inline code/fenced examples)
/// with styling that matches the app theme, instead of raw markdown syntax.
class MarkdownText extends StatelessWidget {
  const MarkdownText({super.key, required this.data, this.selectable = true});

  final String data;

  /// Selectable text claims horizontal drags, so text inside a swipeable
  /// page (the step-by-step lesson) turns selection off to keep swiping.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge,
        strong: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        em: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 17,
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
