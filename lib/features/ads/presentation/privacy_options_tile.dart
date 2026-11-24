import 'package:flutter/material.dart';

import '../data/ad_service.dart';

/// Settings row for the ad consent choices. Only shown where the consent
/// rules require it (for example in the EEA and UK).
class PrivacyOptionsTile extends StatelessWidget {
  const PrivacyOptionsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdService.instance;
    return ValueListenableBuilder<bool>(
      valueListenable: service.privacyOptionsRequired,
      builder: (context, required, _) {
        if (!required) return const SizedBox.shrink();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Privacy options'),
          subtitle: const Text('Change your ad consent choices.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: service.showPrivacyOptions,
        );
      },
    );
  }
}
