enum ExplanationDepth { concise, standard, deep }

enum DifficultyPreference { relaxed, standard, challenging }

/// How many weekly-flashcard notifications to send per day.
enum FlashcardVolume {
  low,
  medium,
  high;

  int get notificationsPerDay => switch (this) {
    FlashcardVolume.low => 2,
    FlashcardVolume.medium => 4,
    FlashcardVolume.high => 8,
  };
}

/// Whether flashcard notification times are picked randomly each day
/// within waking hours, or fixed by the learner.
enum FlashcardFrequencyMode { random, fixed }

/// Which AI backend powers the AI Teacher and exercise generation.
enum AiProviderKind {
  gemini,
  openai,
  anthropic,
  deepseek;

  String get displayName => switch (this) {
    AiProviderKind.gemini => 'Gemini',
    AiProviderKind.openai => 'OpenAI',
    AiProviderKind.anthropic => 'Claude',
    AiProviderKind.deepseek => 'DeepSeek',
  };
}

/// All learner-configurable settings, typed and defaulted.
///
/// See instructions.md section 36.
class AppSettings {
  const AppSettings({
    required this.themeModeKey,
    required this.explanationDepth,
    required this.dailyTargetMinutes,
    required this.difficultyPreference,
    required this.weeklyFlashcardsEnabled,
    required this.flashcardVolume,
    required this.flashcardFrequencyMode,
    required this.flashcardFixedTimes,
    required this.debugMode,
    required this.aiRequestLogging,
    required this.aiProviderKind,
  });

  final String themeModeKey; // 'light' | 'dark' | 'system'
  final ExplanationDepth explanationDepth;
  final int dailyTargetMinutes;
  final DifficultyPreference difficultyPreference;
  final bool weeklyFlashcardsEnabled;
  final FlashcardVolume flashcardVolume;
  final FlashcardFrequencyMode flashcardFrequencyMode;

  /// Only used when [flashcardFrequencyMode] is [FlashcardFrequencyMode.fixed].
  /// Each entry is a "HH:mm" 24-hour local time.
  final List<String> flashcardFixedTimes;
  final bool debugMode;
  final bool aiRequestLogging;
  final AiProviderKind aiProviderKind;

  static const defaults = AppSettings(
    themeModeKey: 'system',
    explanationDepth: ExplanationDepth.standard,
    dailyTargetMinutes: 20,
    difficultyPreference: DifficultyPreference.standard,
    weeklyFlashcardsEnabled: false,
    flashcardVolume: FlashcardVolume.medium,
    flashcardFrequencyMode: FlashcardFrequencyMode.random,
    flashcardFixedTimes: ['09:00', '13:00', '17:00', '20:00'],
    debugMode: false,
    aiRequestLogging: false,
    aiProviderKind: AiProviderKind.gemini,
  );

  AppSettings copyWith({
    String? themeModeKey,
    ExplanationDepth? explanationDepth,
    int? dailyTargetMinutes,
    DifficultyPreference? difficultyPreference,
    bool? weeklyFlashcardsEnabled,
    FlashcardVolume? flashcardVolume,
    FlashcardFrequencyMode? flashcardFrequencyMode,
    List<String>? flashcardFixedTimes,
    bool? debugMode,
    bool? aiRequestLogging,
    AiProviderKind? aiProviderKind,
  }) {
    return AppSettings(
      themeModeKey: themeModeKey ?? this.themeModeKey,
      explanationDepth: explanationDepth ?? this.explanationDepth,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      difficultyPreference: difficultyPreference ?? this.difficultyPreference,
      weeklyFlashcardsEnabled:
          weeklyFlashcardsEnabled ?? this.weeklyFlashcardsEnabled,
      flashcardVolume: flashcardVolume ?? this.flashcardVolume,
      flashcardFrequencyMode:
          flashcardFrequencyMode ?? this.flashcardFrequencyMode,
      flashcardFixedTimes: flashcardFixedTimes ?? this.flashcardFixedTimes,
      debugMode: debugMode ?? this.debugMode,
      aiRequestLogging: aiRequestLogging ?? this.aiRequestLogging,
      aiProviderKind: aiProviderKind ?? this.aiProviderKind,
    );
  }
}
