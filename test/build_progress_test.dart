import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/build_hub/domain/build_progress.dart';

void main() {
  test('counts done and in-progress items per track', () {
    final progress = BuildProgress.fromItems(
      projects: const [
        (started: true, complete: true),
        (started: true, complete: false),
        (started: false, complete: false),
      ],
      systemDesignFinished: const [true, false],
      challengesFinished: const [false, false, false],
    );
    expect(progress.projects.total, 3);
    expect(progress.projects.done, 1);
    expect(progress.projects.inProgress, 1);
    expect(progress.projects.summary, '1 of 3 done, 1 in progress');
    expect(progress.systemDesign.summary, '1 of 2 done');
    expect(progress.systemDesign.fraction, 0.5);
    expect(progress.codingChallenges.summary, '3 to try');
  });

  test('empty track has a friendly summary', () {
    const track = TrackProgress(total: 0, done: 0);
    expect(track.isEmpty, isTrue);
    expect(track.fraction, 0);
    expect(track.summary, 'Nothing available yet');
  });
}
