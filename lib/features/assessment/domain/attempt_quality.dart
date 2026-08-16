import 'models/attempt.dart';

/// How good an attempt was, on a 0.0-1.0 scale — the single shared
/// definition used by both the learning stats provider and the profile
/// XP calculator, so "was this attempt any good" can't silently drift
/// into two different answers.
double qualityOf(Attempt attempt) {
  if (attempt.isCorrect != null) return attempt.isCorrect! ? 1.0 : 0.15;
  return switch (attempt.selfRating) {
    1 => 0.1,
    2 => 0.4,
    3 => 0.75,
    4 => 1.0,
    _ => 0.75,
  };
}
