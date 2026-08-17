enum AppEnvironment { development, staging, production }

/// Build-time capability toggles — distinct from *runtime* configuration
/// like whether an AI provider API key has been entered. See
/// instructions.md section 28 and [features/ai_teacher] for the latter.
class FeatureFlags {
  const FeatureFlags({
    this.aiTeacherEnabled = true,
    this.advancedAssessmentsEnabled = false,
    this.experimentalCurriculumEnabled = false,
    this.projectsEnabled = false,
    this.analyticsEnabled = false,
  });

  final bool aiTeacherEnabled;
  final bool advancedAssessmentsEnabled;
  final bool experimentalCurriculumEnabled;
  final bool projectsEnabled;
  final bool analyticsEnabled;
}

/// Central application configuration.
///
/// This deliberately holds no secrets. Per-user AI provider API keys are
/// entered at runtime and stored via the OS-backed secure storage in
/// features/ai_teacher — never bundled into the app or the source tree.
/// See instructions.md section 27.
class AppConfig {
  const AppConfig({
    this.environment = AppEnvironment.development,
    this.apiBaseUrl = '',
    this.featureFlags = const FeatureFlags(),
    this.geminiApiBaseUrl = 'https://generativelanguage.googleapis.com',
    this.geminiModel = 'gemini-3.7-flash',
    this.openAiApiBaseUrl = 'https://api.openai.com/v1',
    this.openAiModel = 'gpt-5.6-luna',
    this.anthropicApiBaseUrl = 'https://api.anthropic.com',
    this.anthropicModel = 'claude-sonnet-5',
    this.deepSeekApiBaseUrl = 'https://api.deepseek.com',
    this.deepSeekModel = 'deepseek-v4-flash',
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final FeatureFlags featureFlags;

  /// Gemini REST API base URL and model id. Kept here, not hardcoded in
  /// [features/ai_teacher], so bumping the model later is a one-line change.
  /// See instructions.md section 28.
  final String geminiApiBaseUrl;
  final String geminiModel;

  final String openAiApiBaseUrl;
  final String openAiModel;

  final String anthropicApiBaseUrl;
  final String anthropicModel;

  /// DeepSeek's Chat Completions API is wire-compatible with OpenAI's, so
  /// it's served by the same [OpenAiCompatibleProvider] with just this
  /// base URL/model swapped in.
  final String deepSeekApiBaseUrl;
  final String deepSeekModel;
}
