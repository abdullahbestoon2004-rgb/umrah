import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';

/// Standard dashboard list row: leading avatar/image, title + subtitle,
/// trailing metric/chip column. Used for agencies, trips, ads and menu rows
/// so every list shares one silhouette.
class EntityListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool chevron;

  const EntityListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.borderColor,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: borderColor ?? AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.sans(14, weight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if ((subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!,
                          style:
                              AppTheme.sans(11.5, color: AppColors.muted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (chevron) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.muted, size: 15),
              ],
            ],
          ),
        ),
      );
}
