import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/flashcards/presentation/providers/flashcard_providers.dart';
import '../features/settings/domain/settings_models.dart';
import '../features/settings/presentation/providers/settings_providers.dart';
import 'router.dart';
import 'theme.dart';

class TeacherApp extends ConsumerWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Initializes the notification plugin and plans the week's flash
    // card schedule once at startup, then again whenever a
    // flashcard-relevant setting changes.
    ref.watch(flashcardStartupProvider);
    ref.listen<AsyncValue<AppSettings>>(settingsControllerProvider, (
      previous,
      next,
    ) {
      final prev = previous?.valueOrNull;
      final curr = next.valueOrNull;
      // `prev == null` covers the initial loading->data transition, which
      // flashcardStartupProvider already handles — only react here to an
      // actual change after the first successful load.
      if (curr == null || prev == null) return;
      final relevantChange =
          prev.weeklyFlashcardsEnabled != curr.weeklyFlashcardsEnabled ||
          prev.flashcardVolume != curr.flashcardVolume ||
          prev.flashcardFrequencyMode != curr.flashcardFrequencyMode ||
          prev.flashcardFixedTimes != curr.flashcardFixedTimes;
      if (relevantChange) ref.read(refreshFlashcardScheduleProvider)();
    });

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
