import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Classic Islamic star-and-cross (khatam) tessellation: eight-pointed
/// stars built from two overlapping squares, tiled on a grid, with small
/// diamonds filling the cross-shaped gaps. Drawn as a subtle line texture
/// over gradients and headers.
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
        painter: _KhatamPainter(color: color, opacity: opacity, cell: cell),
      ),
    );
  }
}

class _KhatamPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double cell;

  _KhatamPainter({required this.color, required this.opacity, required this.cell});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final r = cell * 0.48; // star radius — tips almost touch across cells

    for (double y = 0; y <= size.height + cell; y += cell) {
      for (double x = 0; x <= size.width + cell; x += cell) {
        _drawStar(canvas, Offset(x, y), r, stroke);
        // small diamond in the middle of each cell (the "cross" filler)
        _drawSquare(canvas, Offset(x + cell / 2, y + cell / 2), r * 0.30, 0, stroke);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    _drawSquare(canvas, c, r, 0, paint); // diamond orientation
    _drawSquare(canvas, c, r, math.pi / 4, paint); // axis-aligned square
  }

  void _drawSquare(Canvas canvas, Offset c, double r, double rot, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = rot + i * math.pi / 2;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KhatamPainter old) =>
      old.color != color || old.opacity != opacity || old.cell != cell;
}
