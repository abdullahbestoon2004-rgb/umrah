import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int? reviews;
  final double size;

  const StarRating({super.key, required this.rating, this.reviews, this.size = 13});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.gold, size: size),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: AppTheme.sans(size - 1, weight: FontWeight.w700),
        ),
        if (reviews != null) ...[
          Text(
            ' · $reviews',
            style: AppTheme.sans(size - 1, color: AppColors.mutedLight),
          ),
        ],
      ],
    );
  }
}
