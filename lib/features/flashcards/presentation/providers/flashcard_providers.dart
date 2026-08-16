import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/flashcard_notification_service.dart';
import '../../domain/generate_weekly_flashcards_use_case.dart';

final generateWeeklyFlashcardsUseCaseProvider =
    Provider<GenerateWeeklyFlashcardsUseCase>((ref) {
      return GenerateWeeklyFlashcardsUseCase(
        progressRepository: ref.watch(studentProgressRepositoryProvider),
        curriculumRepository: ref.watch(curriculumRepositoryProvider),
      );
    });

final flashcardNotificationServiceProvider =
    Provider<FlashcardNotificationService>((ref) {
      return FlashcardNotificationService();
    });

/// Re-plans the week's flashcard notifications from the current settings
/// and progress. Safe to call repeatedly — always cancels and
/// re-schedules from scratch, so it's the single entry point for both
/// "settings changed" and "app just started" triggers.
///
/// Exposed as a provider (rather than a free function taking a [Ref])
/// so it can be invoked identically from a [WidgetRef] (app startup,
/// settings changes) and from inside other providers — [WidgetRef] and
/// [Ref] aren't interchangeable in this Riverpod version, but both can
/// `read` a plain [Provider].
final refreshFlashcardScheduleProvider = Provider<Future<void> Function()>((
  ref,
) {
  return () async {
    final service = ref.read(flashcardNotificationServiceProvider);
    await service.initialize();

    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    if (!settings.weeklyFlashcardsEnabled) {
      await service.cancelAll();
      return;
    }

    final granted = await service.requestPermission();
    if (!granted) return;

    final pool = await ref
        .read(generateWeeklyFlashcardsUseCaseProvider)
        .call();
    await service.scheduleWeek(
      pool: pool,
      volume: settings.flashcardVolume,
      frequencyMode: settings.flashcardFrequencyMode,
      fixedTimes: settings.flashcardFixedTimes,
    );
  };
});

/// Watched once from the app root so the plugin initializes and the
/// week's schedule gets (re)planned on startup.
final flashcardStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(refreshFlashcardScheduleProvider)();
});
