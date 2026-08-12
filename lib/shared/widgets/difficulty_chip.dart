import 'package:flutter/material.dart';

import '../../features/curriculum/domain/models/difficulty.dart';

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(difficulty.label),
      backgroundColor: colorScheme.surfaceContainerHigh,
      labelStyle: Theme.of(context).textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
