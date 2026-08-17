import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Abstract stand-in for photography/3D-render imagery this app doesn't
/// carry (see `subject_style.dart`'s rationale for plain glyphs over
/// "cartoon illustration"-style assets — the same reasoning rules out
/// bundling stock photos here). A handful of soft, feathered gradient
/// circles in the brand's two hues — no image assets, no extra blur pass
/// (whatever [GradientCard] this sits inside already pays for its own
/// [BackdropFilter], so these are gradient-only, not [ImageFiltered]).
///
/// [seed] is a small fixed int, not `.hashCode` — deliberately, so layout
/// stays stable across rebuilds and reads as an intentional composition
/// rather than incidental noise.
class GlassBlobField extends StatelessWidget {
  const GlassBlobField({super.key, required this.seed, this.blobCount = 3});

  final int seed;
  final int blobCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final random = math.Random(seed);
    final blobs = List.generate(blobCount, (i) {
      final usePrimary = i.isEven;
      return (
        dx: random.nextDouble(),
        dy: random.nextDouble(),
        diameter: 70 + random.nextDouble() * 70,
        color: usePrimary ? colorScheme.primary : AppColors.seedAccent,
      );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 160.0;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 160.0;
        return Stack(
          children: [
            for (final blob in blobs)
              Positioned(
                left: blob.dx * width - blob.diameter / 2,
                top: blob.dy * height - blob.diameter / 2,
                child: Container(
                  width: blob.diameter,
                  height: blob.diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        blob.color.withValues(alpha: 0.55),
                        blob.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A small glowing "glass badge" — the abstract stand-in for imagery like
/// the reference mockup's 3D-rendered icon-on-books illustration. A radial
/// glow behind a translucent disc with a thin highlight ring, holding a
/// single centered [icon].
class GlassMedallion extends StatelessWidget {
  const GlassMedallion({
    super.key,
    required this.icon,
    this.size = 52,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = color ?? colorScheme.primary;

    return SizedBox(
      width: size * 1.8,
      height: size * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.8,
            height: size * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.45),
                  accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.46),
          ),
        ],
      ),
    );
  }
}
