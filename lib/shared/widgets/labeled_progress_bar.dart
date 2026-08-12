import 'package:flutter/material.dart';

/// A labeled horizontal progress bar, e.g. "Python  72%".
class LabeledProgressBar extends StatelessWidget {
  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.progress,
    this.trailing,
  });

  final String label;

  /// 0.0 - 1.0
  final double progress;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentLabel = trailing ?? '${(progress.clamp(0, 1) * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(
              percentLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
          ),
        ),
      ],
    );
  }
}
