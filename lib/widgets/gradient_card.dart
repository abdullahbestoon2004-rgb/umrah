import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final Widget? child;

  const GradientCard({
    super.key,
    required this.colors,
    this.height = 96,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          // subtle stripe texture
          ClipRRect(
            borderRadius: borderRadius,
            child: CustomPaint(
              size: Size(width ?? double.infinity, height),
              painter: _StripePainter(),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const spacing = 16.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
