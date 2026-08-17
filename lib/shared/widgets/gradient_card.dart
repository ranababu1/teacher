import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A [Card] with a subtle, corner-anchored gradient sheen
/// ([AppGradients.cardSheen]) layered behind its content. A drop-in
/// replacement for [Card] — forwards the same parameters this app's call
/// sites actually use.
///
/// `Card.color` is a flat [Color], with no theme-level hook for a
/// gradient fill, so this wrapper is the mechanism for applying the sheen
/// app-wide without touching [CardThemeData].
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.margin,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;

  /// Defaults to [Clip.antiAlias] (unlike [Card]'s own default of
  /// [Clip.none]) so the sheen clips to the card's rounded corners
  /// instead of poking past them.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: shape,
      clipBehavior: clipBehavior,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.cardSheen(colorScheme)),
        child: child,
      ),
    );
  }
}
