enum ExplanationDepth { concise, standard, deep }

enum DifficultyPreference { relaxed, standard, challenging }

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
    required this.debugMode,
    required this.aiRequestLogging,
  });

  final String themeModeKey; // 'light' | 'dark' | 'system'
  final ExplanationDepth explanationDepth;
  final int dailyTargetMinutes;
  final DifficultyPreference difficultyPreference;
  final bool weeklyFlashcardsEnabled;
  final bool debugMode;
  final bool aiRequestLogging;

  static const defaults = AppSettings(
    themeModeKey: 'system',
    explanationDepth: ExplanationDepth.standard,
    dailyTargetMinutes: 20,
    difficultyPreference: DifficultyPreference.standard,
    weeklyFlashcardsEnabled: false,
    debugMode: false,
    aiRequestLogging: false,
  );

  AppSettings copyWith({
    String? themeModeKey,
    ExplanationDepth? explanationDepth,
    int? dailyTargetMinutes,
    DifficultyPreference? difficultyPreference,
    bool? weeklyFlashcardsEnabled,
    bool? debugMode,
    bool? aiRequestLogging,
  }) {
    return AppSettings(
      themeModeKey: themeModeKey ?? this.themeModeKey,
      explanationDepth: explanationDepth ?? this.explanationDepth,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      difficultyPreference: difficultyPreference ?? this.difficultyPreference,
      weeklyFlashcardsEnabled: weeklyFlashcardsEnabled ?? this.weeklyFlashcardsEnabled,
      debugMode: debugMode ?? this.debugMode,
      aiRequestLogging: aiRequestLogging ?? this.aiRequestLogging,
    );
  }
}
