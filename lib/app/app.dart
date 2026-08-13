import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/providers/settings_providers.dart';
import 'router.dart';
import 'theme.dart';

class TeacherApp extends ConsumerWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Teacher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final theme = Theme.of(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: AppGradients.scaffold(
              theme.colorScheme,
              theme.brightness == Brightness.dark,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
