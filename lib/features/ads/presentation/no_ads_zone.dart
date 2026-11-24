import 'package:flutter/widgets.dart';

import '../data/ad_service.dart';

/// Wrap a screen in this to keep interstitials away while it is open:
/// tests, quizzes, practice, challenges, interview and review sessions.
class NoAdsZone extends StatefulWidget {
  const NoAdsZone({super.key, required this.child});

  final Widget child;

  @override
  State<NoAdsZone> createState() => _NoAdsZoneState();
}

class _NoAdsZoneState extends State<NoAdsZone> {
  @override
  void initState() {
    super.initState();
    AdService.instance.gate.enterNoAdsZone();
  }

  @override
  void dispose() {
    AdService.instance.gate.exitNoAdsZone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
