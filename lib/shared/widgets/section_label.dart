import 'package:flutter/material.dart';

/// A small uppercase "eyebrow" label for section headers — replaces a
/// plain `titleMedium` heading everywhere a screen groups content under a
/// name like "Learning Progress" or "Recent Activity". Pulling section
/// headers down in visual weight (muted, letter-spaced, smaller) is what
/// lets bigger things — a headline, a card's own content — read as the
/// actual focal point, instead of every piece of text competing at the
/// same size.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
