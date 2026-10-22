import 'models/roadmap.dart';

/// Stores the learner's single saved roadmap on the device.
abstract class RoadmapRepository {
  /// The saved roadmap, or null when there is none (or it is unreadable).
  Future<Roadmap?> load();

  Future<void> save(Roadmap roadmap);

  Future<void> clear();
}
