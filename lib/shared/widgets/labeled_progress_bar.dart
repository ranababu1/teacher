import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A labeled horizontal progress bar, e.g. "Python  72%".
///
/// Fills with a subtle brand gradient and animates from its previous value
/// whenever [progress] changes, instead of snapping instantly.
class LabeledProgressBar extends StatelessWidget {
  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.progress,
    this.trailing,
    this.color,
  });

  final String label;

  /// 0.0 - 1.0
  final double progress;
  final String? trailing;

  /// Overrides the default brand-gradient fill with a solid color — used
  /// where a row needs its own identity (e.g. a per-subject color) rather
  /// than the shared brand gradient. Omit to keep the existing look.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress.clamp(0, 1).toDouble();
    final percentLabel = trailing ?? '${(clamped * 100).round()}%';

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
          child: Container(
            height: 8,
            color: theme.colorScheme.surfaceContainerHigh,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    gradient: color == null
                        ? AppGradients.progress(theme.colorScheme)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
