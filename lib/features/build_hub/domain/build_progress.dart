/// Progress across the hands-on tracks: guided projects, system design
/// walkthroughs and long-form coding challenges.
class TrackProgress {
  const TrackProgress({
    required this.total,
    required this.done,
    this.inProgress = 0,
  });

  final int total;

  /// Projects with every milestone ticked; exercises and challenges
  /// finished at least once.
  final int done;

  /// Projects with some, but not all, milestones ticked.
  final int inProgress;

  bool get isEmpty => total == 0;

  double get fraction => total == 0 ? 0 : done / total;

  /// Short status line such as "2 of 10 done, 1 in progress".
  String get summary {
    if (total == 0) return 'Nothing available yet';
    if (done == 0 && inProgress == 0) return '$total to try';
    final parts = ['$done of $total done'];
    if (inProgress > 0) parts.add('$inProgress in progress');
    return parts.join(', ');
  }
}

class BuildProgress {
  const BuildProgress({
    required this.projects,
    required this.systemDesign,
    required this.codingChallenges,
  });

  final TrackProgress projects;
  final TrackProgress systemDesign;
  final TrackProgress codingChallenges;

  /// Builds the summary from per-item completion flags.
  factory BuildProgress.fromItems({
    required Iterable<({bool started, bool complete})> projects,
    required Iterable<bool> systemDesignFinished,
    required Iterable<bool> challengesFinished,
  }) {
    final p = projects.toList();
    final sd = systemDesignFinished.toList();
    final cc = challengesFinished.toList();
    return BuildProgress(
      projects: TrackProgress(
        total: p.length,
        done: p.where((e) => e.complete).length,
        inProgress: p.where((e) => e.started && !e.complete).length,
      ),
      systemDesign: TrackProgress(
        total: sd.length,
        done: sd.where((e) => e).length,
      ),
      codingChallenges: TrackProgress(
        total: cc.length,
        done: cc.where((e) => e).length,
      ),
    );
  }
}
