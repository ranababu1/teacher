import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const seed = Color(0xFF3D6BFF);
const seedAccent = Color(0xFF8B5CF6);

/// A simple graduation-cap mark, drawn as plain vector shapes rather than
/// an icon-font glyph — font rendering isn't reliable inside `flutter
/// test`'s VM runner (icon fonts show up as missing-glyph boxes there),
/// but pure Path/Canvas drawing renders correctly regardless.
class GraduationCap extends StatelessWidget {
  const GraduationCap({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _CapPainter(color));
  }
}

class _CapPainter extends CustomPainter {
  _CapPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Flattened diamond = the mortarboard's flat top.
    final diamond = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.95, h * 0.32)
      ..lineTo(w * 0.5, h * 0.56)
      ..lineTo(w * 0.05, h * 0.32)
      ..close();
    canvas.drawPath(diamond, paint);

    // Head band beneath the diamond.
    final bandRect = RRect.fromLTRBR(
      w * 0.30,
      h * 0.44,
      w * 0.70,
      h * 0.68,
      const Radius.circular(4),
    );
    canvas.drawRRect(bandRect, paint);

    // Tassel string + button, hanging from the diamond's right edge.
    final stringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final stringPath = Path()
      ..moveTo(w * 0.78, h * 0.30)
      ..lineTo(w * 0.78, h * 0.52)
      ..lineTo(w * 0.66, h * 0.62);
    canvas.drawPath(stringPath, stringPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.66), w * 0.05, paint);
  }

  @override
  bool shouldRepaint(covariant _CapPainter oldDelegate) =>
      oldDelegate.color != color;
}

Future<void> capture(
  WidgetTester tester,
  Widget child,
  String name, {
  double size = 1024,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        child: SizedBox(width: size, height: size, child: child),
      ),
    ),
  );
  await tester.pump();
  await expectLater(
    find.byType(RepaintBoundary),
    matchesGoldenFile('icon/$name.png'),
  );
}

void main() {
  testWidgets('generate full icon (gradient + glyph)', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;
    await capture(
      tester,
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [seed, seedAccent],
          ),
        ),
        child: const Center(
          child: GraduationCap(size: 580, color: Colors.white),
        ),
      ),
      'app_icon_full',
    );
  });

  testWidgets('generate adaptive background (flat gradient, no glyph)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;
    await capture(
      tester,
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [seed, seedAccent],
          ),
        ),
      ),
      'app_icon_background',
    );
  });

  testWidgets(
    'generate adaptive foreground (transparent + glyph, safe-zone padded)',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1.0;
      await capture(
        tester,
        const Center(child: GraduationCap(size: 440, color: Colors.white)),
        'app_icon_foreground',
      );
    },
  );
}
