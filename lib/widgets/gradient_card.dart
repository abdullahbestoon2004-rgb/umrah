import 'package:flutter/material.dart';
import 'islamic_pattern.dart';

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
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // small cards get a tighter tile so the motif stays visible
            IslamicPattern(cell: height < 120 ? 40 : 62, opacity: 0.09),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
