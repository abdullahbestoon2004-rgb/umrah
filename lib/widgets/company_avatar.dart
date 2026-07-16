import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CompanyAvatar extends StatelessWidget {
  final String mono;
  final Color tint;
  final String? logoUrl;
  final double size;
  final double fontSize;
  final double borderRadius;

  const CompanyAvatar({
    super.key,
    required this.mono,
    required this.tint,
    this.logoUrl,
    this.size = 56,
    this.fontSize = 24,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(mono, style: AppTheme.serif(fontSize, color: Colors.white)),
    );

    if ((logoUrl ?? '').isEmpty) return fallback;

    final dpr = MediaQuery.of(context).devicePixelRatio;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        // decode at display size to keep list scrolling cheap
        cacheWidth: (size * dpr).round(),
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
