import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// How strongly a [GradientCard] leans into the glass look.
///
/// [dark] is reserved for exactly one or two "hero" surfaces per screen
/// (e.g. the Dashboard's hero card and its one featured stat tile) — it's
/// the only variant that pays for a real [BackdropFilter] blur. [adaptive]
/// (the default, used for every ordinary card) fakes the glass look with
/// translucency + a gradient border + a shadow and skips the blur, so a
/// screen with a dozen visible cards never runs a dozen simultaneous GPU
/// blur passes.
enum GlassTint { adaptive, dark }

/// A translucent, frosted "Liquid Glass" card — a drop-in replacement for
/// [Card] (forwards the same parameters this app's call sites use).
///
/// Composition: an outer drop shadow (depth driven by [elevation]) around
/// a clipped rounded rect containing a translucent fill, the pre-existing
/// [AppGradients.cardSheen] corner tint (kept for continuity with the
/// pre-glass look), and a soft gradient-stroke border for the glass edge
/// highlight — [BoxDecoration.border] can't paint a gradient stroke, so
/// that's a small [CustomPainter]. [child] renders on top through a
/// transparent [Material] (so `InkWell`/`ListTile` children still ripple
/// correctly) and stays fully opaque, so text is crisp against the
/// blurred backdrop.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.margin,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
    this.tint = GlassTint.adaptive,
  });

  final Widget child;

  /// Blended at low alpha into the glass fill when set. Rarely needed —
  /// the fill is computed from the theme by default. (In the pre-glass
  /// version of this widget, this was an opaque `Card.color` override;
  /// glass has no opaque backing to override, so this is now just a tint.)
  final Color? color;

  /// Reinterpreted as a shadow-depth tier (see [AppElevation]) rather than
  /// a Material elevation, since glass has no elevation-tinted surface to
  /// drive.
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final GlassTint tint;

  static const double _blurSigma = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final forceDark = tint == GlassTint.dark;
    final isDark = forceDark || colorScheme.brightness == Brightness.dark;
    final radius = _radiusFrom(shape);
    final depth = elevation ?? AppElevation.standard;

    final glassStack = Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _fill(colorScheme, isDark)),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.cardSheen(colorScheme),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _GlassBorderPainter(isDark: isDark, radius: radius),
          ),
        ),
        Material(type: MaterialType.transparency, child: child),
      ],
    );

    return Container(
      margin: margin ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: isDark ? 0.35 : 0.10 + depth * 0.025,
            ),
            blurRadius: 16 + depth * 6,
            offset: Offset(0, 4 + depth * 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: forceDark
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurSigma,
                  sigmaY: _blurSigma,
                ),
                child: glassStack,
              )
            : glassStack,
      ),
    );
  }

  BorderRadius _radiusFrom(ShapeBorder? shape) {
    if (shape is RoundedRectangleBorder && shape.borderRadius is BorderRadius) {
      return shape.borderRadius as BorderRadius;
    }
    return BorderRadius.circular(16);
  }

  LinearGradient _fill(ColorScheme colorScheme, bool isDark) {
    final tintColor = color ?? colorScheme.primary;
    if (isDark) {
      const base = AppColors.darkSurface;
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            tintColor.withValues(alpha: 0.10),
            base,
          ).withValues(alpha: 0.72),
          base.withValues(alpha: 0.90),
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.alphaBlend(
          tintColor.withValues(alpha: 0.06),
          Colors.white,
        ).withValues(alpha: 0.62),
        Colors.white.withValues(alpha: 0.34),
      ],
    );
  }
}

/// Paints [GradientCard]'s glass edge highlight — a soft diagonal
/// gradient stroke that [BoxDecoration.border] can't express on its own.
class _GlassBorderPainter extends CustomPainter {
  const _GlassBorderPainter({required this.isDark, required this.radius});

  final bool isDark;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = radius.toRRect(rect).deflate(0.6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.03),
              ]
            : [
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.20),
              ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.radius != radius;
}
