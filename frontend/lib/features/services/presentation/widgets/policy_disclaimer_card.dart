import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mystic_card.dart';

class PolicyDisclaimerCard extends StatelessWidget {
  final VoidCallback? onDismiss;

  const PolicyDisclaimerCard({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return MysticCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: AppColors.astralGold.withValues(alpha: 0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.astralGold.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.shield_moon_outlined,
              size: 20,
              color: AppColors.astralGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Platform Disclaimer & Ethics',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.astralGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Readings offer intuitive spiritual guidance, not absolute guarantees. By platform policy, no questions regarding medical diagnosis, legal disputes, or pregnancy are permitted.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
