import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';

/// Shown in place of a module's content when its topic test gate hasn't
/// been passed yet — reached via a deep link or stale back-stack entry,
/// since normal navigation never lets you get this far ungated. Mirrors
/// [CourseLockedState]'s layout conventions.
class TopicLockedState extends StatelessWidget {
  const TopicLockedState({
    super.key,
    required this.pathId,
    required this.previousModuleId,
  });

  final String pathId;
  final String previousModuleId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              "Pass the previous topic's test to unlock this one.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  context.go(Routes.module(pathId, previousModuleId)),
              child: const Text('Go to previous topic'),
            ),
          ],
        ),
      ),
    );
  }
}
