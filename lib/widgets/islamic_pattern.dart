import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Girih-style Islamic pattern: six-pointed stars alternating with
/// hexagons on a triangular lattice, every shape drawn with a double
/// parallel outline (strapwork), like classic tile work.
class IslamicPattern extends StatelessWidget {
  final double opacity;
  final Color color;
  final double cell;

  const IslamicPattern({
    super.key,
    this.opacity = 0.08,
    this.color = Colors.white,
    this.cell = 56,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GirihPainter(color: color, opacity: opacity, cell: cell),
      ),
    );
  }
}

class _GirihPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;

  _GirihPainter({required this.color, required this.opacity, required this.cell});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;

    final a = cell; // horizontal lattice spacing
    final h = a * math.sqrt(3) / 2; // row height
    final r = a * 0.55; // shape radius — near-touching neighbours

    var j = 0;
    for (double y = -h; y <= size.height + h; y += h, j++) {
      final rowOffset = j.isOdd ? a / 2 : 0.0;
      var i = 0;
      for (double x = -a + rowOffset; x <= size.width + a; x += a, i++) {
        // Triangular lattice split into 3 sublattices: stars on one,
        // hexagons on another, the third left open (breathing room).
        final t = (i + 2 * j) % 3;
        final c = Offset(x, y);
        if (t == 0) {
          _star(canvas, c, r, stroke);
          _star(canvas, c, r * 0.78, stroke);
        } else if (t == 1) {
          _hexagon(canvas, c, r * 0.92, stroke);
          _hexagon(canvas, c, r * 0.92 * 0.78, stroke);
        }
      }
    }
  }

  /// Six-pointed star outline (hexagram silhouette, 12 vertices).
  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final inner = r / math.sqrt(3);
    final path = Path();
    for (var k = 0; k < 12; k++) {
      final outerPoint = k.isEven;
      final rad = outerPoint ? r : inner;
      final ang = k * math.pi / 6 - math.pi / 2;
      final p = Offset(c.dx + rad * math.cos(ang), c.dy + rad * math.sin(ang));
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _hexagon(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var k = 0; k < 6; k++) {
      final ang = k * math.pi / 3 - math.pi / 2;
      final p = Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang));
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GirihPainter old) =>
      old.color != color || old.opacity != opacity || old.cell != cell;
}
