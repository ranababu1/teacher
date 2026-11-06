/// Anthropic's Messages API requires `max_tokens` (there is no omit-and-
/// use-default path). Soft length (~10000 tokens) is enforced by prompts
/// for every provider; this value is only the model's documented max
/// output so the app never invents a low artificial cap.
int maxTokensForAnthropicModel(String model) {
  final m = model.toLowerCase();

  // Current Claude 5.x lineup: 128k sync max output.
  if (m.contains('sonnet-5') ||
      m.contains('opus-5') ||
      m.contains('haiku-5') ||
      m.contains('fable-5') ||
      m.contains('mythos-5')) {
    return 128000;
  }

  // Claude 4.6: 128k.
  if (m.contains('sonnet-4-6') || m.contains('opus-4-6')) {
    return 128000;
  }

  // Claude 4.5 / Sonnet 4.x: 64k.
  if (m.contains('sonnet-4') ||
      m.contains('haiku-4-5') ||
      m.contains('opus-4-5')) {
    return 64000;
  }

  // Other Claude 4 Opus: 32k.
  if (m.contains('opus-4')) {
    return 32000;
  }

  // Claude 3.7: 64k.
  if (m.contains('3-7') || m.contains('3.7')) {
    return 64000;
  }

  // Claude 3.5: 8k.
  if (m.contains('3-5') || m.contains('3.5')) {
    return 8192;
  }

  // Claude 3.0: 4k.
  if (m.contains('claude-3') || m.contains('claude-instant')) {
    return 4096;
  }

  // Unknown model id: prefer the current-generation ceiling over a low guess.
  return 128000;
}
