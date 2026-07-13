import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

/// A visual password strength indicator that shows colored bars + label.
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = Validators.passwordStrength(password);
    if (password.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppColors.errorRed,
      const Color(0xFFFF8C00),
      const Color(0xFFFFCC00),
      const Color(0xFF34C759),
    ];
    final color = score > 0 ? colors[(score - 1).clamp(0, 3)] : AppColors.muted;
    final label = Validators.strengthLabel(score);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < score ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.sans(11, color: color, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
