import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Girih-style Islamic geometric pattern.
/// - If [isEightFold] is false (default), it renders the original 6-pointed star
///   and hexagon pattern (used for cards).
/// - If [isEightFold] is true, it renders the new 8-pointed star and circular
///   rosette pattern (used for general app background).
class IslamicPattern extends StatelessWidget {
  final double opacity;
  final Color color;
  final double cell;
  final bool isEightFold;

  const IslamicPattern({
    super.key,
    this.opacity = 0.08,
    this.color = const Color(0xFFC9A24B), // Premium Gold color by default
    this.cell = 80,
    this.isEightFold = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GirihPainter(
          color: color,
          opacity: opacity,
          cell: cell,
          isEightFold: isEightFold,
        ),
      ),
    );
  }
}

class _GirihPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;
  final bool isEightFold;

  _GirihPainter({
    required this.color,
    required this.opacity,
    required this.cell,
    required this.isEightFold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;

    if (isEightFold) {
      _paintEightFold(canvas, size, stroke);
    } else {
      _paintSixFold(canvas, size, stroke);
    }
  }

  void _paintEightFold(Canvas canvas, Size size, Paint stroke) {
    final a = cell;
    final double rStar = a * 0.22;
    final double rCircle = a * 0.38;
    final double dCircle = a * 0.32;

    for (double y = 0; y <= size.height + a; y += a) {
      for (double x = 0; x <= size.width + a; x += a) {
        final c = Offset(x, y);

        // 1. Draw 8-pointed star in the center (double outline)
        _star8(canvas, c, rStar, stroke);
        _star8(canvas, c, rStar * 0.8, stroke);

        // 2. Draw 8 overlapping rosette circles (double outline)
        for (int i = 0; i < 8; i++) {
          final double angle = i * math.pi / 4;
          final Offset circleCenter =
              c + Offset(math.cos(angle), math.sin(angle)) * dCircle;
          canvas.drawCircle(circleCenter, rCircle, stroke);
          canvas.drawCircle(circleCenter, rCircle * 0.92, stroke);
        }
      }
    }
  }

  void _paintSixFold(Canvas canvas, Size size, Paint stroke) {
    final a = cell;
    final h = a * math.sqrt(3) / 2; // row height
    final r = a * 0.55; // shape radius

    var j = 0;
    for (double y = -h; y <= size.height + h; y += h, j++) {
      final rowOffset = j.isOdd ? a / 2 : 0.0;
      var i = 0;
      for (double x = -a + rowOffset; x <= size.width + a; x += a, i++) {
        final t = (i + 2 * j) % 3;
        final c = Offset(x, y);
        if (t == 0) {
          _star6(canvas, c, r, stroke);
          _star6(canvas, c, r * 0.78, stroke);
        } else if (t == 1) {
          _hexagon(canvas, c, r * 0.92, stroke);
          _hexagon(canvas, c, r * 0.92 * 0.78, stroke);
        }
      }
    }
  }

  /// Draws an 8-pointed star (16 vertices).
  void _star8(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    final double innerR = r * 0.54;
    for (int k = 0; k < 16; k++) {
      final double rad = k.isEven ? r : innerR;
      final double ang = k * math.pi / 8 - math.pi / 2;
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

  /// Six-pointed star (12 vertices).
  void _star6(Canvas canvas, Offset c, double r, Paint paint) {
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
      old.color != color ||
      old.opacity != opacity ||
      old.cell != cell ||
      old.isEightFold != isEightFold;
}
