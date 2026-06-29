import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFF6F2E9) : const Color(0xFF3C4A43);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.primary.withOpacity(0.16),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
            ],
            Text(label, style: AppTheme.sans(13, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final Widget? icon;

  const InfoChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 5)],
          Text(label, style: AppTheme.sans(11.5, weight: FontWeight.w600, color: const Color(0xFF5E6B63))),
        ],
      ),
    );
  }
}
