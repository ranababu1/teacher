import 'package:flutter/material.dart';

import '../../domain/models/mastery_status.dart';

class MasteryStatusIcon extends StatelessWidget {
  const MasteryStatusIcon({super.key, required this.status, this.size = 16});

  final MasteryStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      MasteryStatus.notStarted => (Icons.circle_outlined, colorScheme.onSurfaceVariant),
      MasteryStatus.learning => (Icons.donut_small, colorScheme.tertiary),
      MasteryStatus.developing => (Icons.incomplete_circle, colorScheme.tertiary),
      MasteryStatus.proficient => (Icons.check_circle_outline, colorScheme.primary),
      MasteryStatus.mastered => (Icons.check_circle, colorScheme.primary),
      MasteryStatus.needsReview => (Icons.replay_circle_filled_outlined, colorScheme.error),
    };
    return Tooltip(
      message: status.label,
      child: Icon(icon, size: size, color: color),
    );
  }
}
