import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';

/// Shown in place of a lesson/module's content when its learning path
/// hasn't been Started yet — reached via a deep link or stale back-stack
/// entry, since normal navigation never lets you get this far unstarted.
/// Mirrors [ErrorState]/[EmptyState]'s layout conventions.
class CourseLockedState extends StatelessWidget {
  const CourseLockedState({super.key, required this.pathId});

  final String pathId;

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
              "This course hasn't been started yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go(Routes.learningPath(pathId)),
              child: const Text('Go to course'),
            ),
          ],
        ),
      ),
    );
  }
}
