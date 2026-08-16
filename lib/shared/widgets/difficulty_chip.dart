import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/curriculum/domain/models/difficulty.dart';

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.difficulty});

  final Difficulty difficulty;

  Color _color() => switch (difficulty) {
    Difficulty.beginner => AppColors.success,
    Difficulty.intermediate => AppColors.warning,
    Difficulty.advanced => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Chip(
      label: Text(difficulty.label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
