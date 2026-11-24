import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

/// Public pages the app links out to. Kept in one place so a URL change
/// is a one-line edit.
abstract final class ExternalLinks {
  static const support = 'https://imrn.dev/products/teacher/support';

  /// Support form with "AI reply problem" preselected. Required by Google
  /// Play's AI-generated content policy: every AI reply must be reportable.
  static const reportAiReply = '$support?type=ai';

  static const privacyPolicy =
      'https://imrn.dev/products/teacher/privacy-policy';
}

/// Opens [url] in the system browser. When no browser can take it, copies
/// the URL to the clipboard and says so, so the learner is never stuck.
Future<void> openExternalLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (opened) return;
  await Clipboard.setData(ClipboardData(text: url));
  messenger?.showSnackBar(
    const SnackBar(
      content: Text('No browser found. The link was copied to the clipboard.'),
    ),
  );
}
