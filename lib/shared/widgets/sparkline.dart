import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A tiny, purely decorative trend squiggle for Dashboard stat tiles —
/// NOT a real historical chart. This app has no daily-history data model
/// to plot (confirmed: no `fl_chart` dependency, no time-series table), so
/// this deterministically derives a plausible-looking curve from [value]
/// and [seed] rather than pretending to show real data. [seed] is a small
/// fixed int (not `.hashCode`) so a screen with several tiles shows
/// visually distinct squiggles instead of an identical shape repeated.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.value,
    required this.seed,
    this.color,
    this.height = 32,
  });

  /// Normalized 0.0-1.0 — the squiggle trends toward this by its final
  /// point, so it reads as "roughly where this metric stands" rather than
  /// a literal series.
  final double value;
  final int seed;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(points: _points(), color: lineColor),
      ),
    );
  }

  List<double> _points({int count = 12}) {
    final random = math.Random(seed);
    final clamped = value.clamp(0.0, 1.0);
    final points = <double>[
      for (var i = 0; i < count; i++)
        (0.15 + clamped * 0.7 * (i / (count - 1)) + (random.nextDouble() - 0.5) * 0.18)
            .clamp(0.05, 0.95),
    ];
    points[count - 1] = (0.1 + clamped * 0.8).clamp(0.05, 0.95);
    return points;
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final dx = size.width / (points.length - 1);
    Offset pointAt(int i) => Offset(dx * i, size.height * (1 - points[i]));

    final line = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = pointAt(i);
      final next = pointAt(i + 1);
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      line.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    final last = pointAt(points.length - 1);
    line.lineTo(last.dx, last.dy);

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
