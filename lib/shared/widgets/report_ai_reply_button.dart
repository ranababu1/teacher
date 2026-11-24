import 'package:flutter/material.dart';

import '../utils/external_links.dart';

/// Small flag button shown on every AI-generated reply or explanation.
/// Opens the support form with "AI reply problem" preselected, so
/// learners can report harmful, wrong or offensive AI output.
class ReportAiReplyButton extends StatelessWidget {
  const ReportAiReplyButton({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('report-ai-reply'),
      tooltip: 'Report this reply',
      visualDensity: VisualDensity.compact,
      iconSize: size,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      icon: const Icon(Icons.flag_outlined),
      onPressed: () => openExternalLink(context, ExternalLinks.reportAiReply),
    );
  }
}
