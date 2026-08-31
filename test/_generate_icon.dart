import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The icon's own background gradient (dark slate -> pale lavender,
// diagonal) — matches the reference artwork the user supplied, not the
// app's blue/purple brand seed colors used elsewhere in the UI. The logo
// is deliberately its own thing, not a themed extension of the in-app
// palette.
const _bgStart = Color(0xFF2B2E3D);
const _bgEnd = Color(0xFFD8D5DF);

/// A stack of five books, drawn as plain vector shapes rather than an
/// icon-font glyph — font rendering isn't reliable inside `flutter
/// test`'s VM runner (icon fonts show up as missing-glyph boxes there),
/// but pure Path/Canvas drawing renders correctly regardless.
class BookStack extends StatelessWidget {
  const BookStack({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _BookStackPainter());
  }
}

class _Book {
  const _Book({
    required this.frontColor,
    required this.topColor,
    required this.centerY,
    required this.height,
    required this.width,
    required this.rotationDegrees,
  });

  final Color frontColor;
  final Color topColor;
  final double centerY;
  final double height;
  final double width;
  final double rotationDegrees;
}

class _BookStackPainter extends CustomPainter {
  static const _pageStripe = Color(0xFFF3E1C3);

  // Bottom to top, so painting order stacks correctly (bottom book drawn
  // first, top book drawn last/on top).
  static const _books = [
    _Book(
      frontColor: Color(0xFFB86B80),
      topColor: Color(0xFFCE8A9C),
      centerY: 0.775,
      height: 0.145,
      width: 0.82,
      rotationDegrees: -1.5,
    ),
    _Book(
      frontColor: Color(0xFFC9A0D6),
      topColor: Color(0xFFDBBBE4),
      centerY: 0.635,
      height: 0.135,
      width: 0.80,
      rotationDegrees: 1.5,
    ),
    _Book(
      frontColor: Color(0xFFF0AA8C),
      topColor: Color(0xFFF6C6AF),
      centerY: 0.50,
      height: 0.135,
      width: 0.79,
      rotationDegrees: -1.2,
    ),
    _Book(
      frontColor: Color(0xFFCE5D86),
      topColor: Color(0xFFE0839F),
      centerY: 0.365,
      height: 0.135,
      width: 0.78,
      rotationDegrees: 1.2,
    ),
    _Book(
      frontColor: Color(0xFFF6DDBB),
      topColor: Color(0xFFFBECD6),
      centerY: 0.235,
      height: 0.135,
      width: 0.76,
      rotationDegrees: -1.0,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final book in _books) {
      _paintBook(canvas, w, h, book);
    }
  }

  void _paintBook(Canvas canvas, double w, double h, _Book book) {
    canvas.save();
    canvas.translate(w * 0.5, h * book.centerY);
    canvas.rotate(book.rotationDegrees * 3.14159265 / 180);

    final bookW = w * book.width;
    final bookH = h * book.height;
    final topH = bookH * 0.32;

    // Front face — a rounded bar, the book's spine as seen face-on.
    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(-bookW / 2, -bookH / 2 + topH, bookW, bookH - topH),
      Radius.circular(bookH * 0.22),
    );
    canvas.drawRRect(front, Paint()..color = book.frontColor);

    // Top edge sliver — a slightly lighter cap, giving the bar a touch of
    // dimension without full 3D perspective.
    final top = RRect.fromRectAndRadius(
      Rect.fromLTWH(-bookW / 2, -bookH / 2, bookW, topH + bookH * 0.05),
      Radius.circular(bookH * 0.22),
    );
    canvas.drawRRect(top, Paint()..color = book.topColor);

    // Page-edge stripe near the right end, with two short gilt ticks —
    // the detail that reads as "book" rather than "plain bar".
    final stripeX = bookW * 0.32;
    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(stripeX, -bookH / 2 + topH, bookW * 0.05, bookH - topH),
      Radius.circular(bookH * 0.1),
    );
    canvas.drawRRect(stripeRect, Paint()..color = _pageStripe.withValues(alpha: 0.55));

    final tickPaint = Paint()
      ..color = _pageStripe
      ..strokeWidth = bookH * 0.05
      ..strokeCap = StrokeCap.round;
    final tickY1 = -bookH / 2 + topH + (bookH - topH) * 0.35;
    final tickY2 = -bookH / 2 + topH + (bookH - topH) * 0.65;
    canvas.drawLine(
      Offset(-bookW * 0.42, tickY1),
      Offset(-bookW * 0.30, tickY1),
      tickPaint,
    );
    canvas.drawLine(
      Offset(-bookW * 0.42, tickY2),
      Offset(-bookW * 0.30, tickY2),
      tickPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BookStackPainter oldDelegate) => false;
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
  testWidgets('generate full icon (gradient + book stack)', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1.0;
    await capture(
      tester,
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgStart, _bgEnd],
          ),
        ),
        child: const Center(child: BookStack(size: 620)),
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
            colors: [_bgStart, _bgEnd],
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
        const Center(child: BookStack(size: 460)),
        'app_icon_foreground',
      );
    },
  );
}
