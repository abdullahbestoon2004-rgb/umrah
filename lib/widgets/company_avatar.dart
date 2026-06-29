import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompanyAvatar extends StatelessWidget {
  final String mono;
  final Color tint;
  final double size;
  final double fontSize;
  final double borderRadius;

  const CompanyAvatar({
    super.key,
    required this.mono,
    required this.tint,
    this.size = 56,
    this.fontSize = 24,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        mono,
        style: AppTheme.serif(fontSize, color: Colors.white),
      ),
    );
  }
}
