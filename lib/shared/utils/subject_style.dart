import 'package:flutter/material.dart';

/// A deterministic, stable hue per learning path — categorical wayfinding
/// (which subject is this?), never an achievement signal, applied
/// uniformly regardless of progress. Every current and future subject
/// (see instructions.md section 9: "future subjects should be addable
/// without changing the UI architecture") gets a distinct identity color
/// with zero maintenance, since the hue is derived from the id itself.
Color subjectColor(String pathId, Brightness brightness) {
  final hue = (_stableHash(pathId) % 360).toDouble();
  return HSLColor.fromAHSL(
    1,
    hue,
    0.42,
    brightness == Brightness.dark ? 0.68 : 0.42,
  ).toColor();
}

/// A hand-written hash rather than [String.hashCode] — `hashCode` is only
/// guaranteed stable within a single process run, not across Dart/Flutter
/// versions, so relying on it here would risk a subject's identity color
/// silently shifting after a future SDK upgrade.
int _stableHash(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

/// A curated Material glyph per curriculum `iconName` — plain icons, not
/// brand logos (no SVG/logo assets exist in this project, and literal
/// logos would drift toward the "cartoon illustration" territory
/// instructions.md section 7 rules out).
IconData subjectIcon(String iconName) => switch (iconName) {
  'python' => Icons.data_object,
  'react' => Icons.widgets_outlined,
  'java' => Icons.coffee_outlined,
  'springboot' => Icons.eco_outlined,
  'nodejs' => Icons.hexagon_outlined,
  'go' => Icons.bolt_outlined,
  'postgres' => Icons.storage_outlined,
  'pinecone' => Icons.scatter_plot_outlined,
  'ai' => Icons.psychology_outlined,
  'llm' => Icons.forum_outlined,
  'docker' => Icons.view_in_ar_outlined,
  'kubernetes' => Icons.account_tree_outlined,
  'systemdesign' => Icons.architecture_outlined,
  'aws' => Icons.cloud_outlined,
  'devops' => Icons.autorenew,
  _ => Icons.menu_book_outlined,
};
