import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../../../../models/reading_service_model.dart';

class ServiceCard extends StatelessWidget {
  final ReadingServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTarot = service.categoryName.toUpperCase().contains('TAROT');
    final isRune = service.categoryName.toUpperCase().contains('RUNE');
    final isCombo = service.categoryName.toUpperCase().contains('COMBO');

    Color categoryColor = AppColors.sacredPurple;
    if (isRune) {
      categoryColor = const Color(0xFF4EA8DE); // Nordic Ice Blue
    } else if (isCombo) {
      categoryColor = AppColors.astralGold;
    }

    return MysticCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Badge & Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: categoryColor.withValues(alpha: 0.15),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTarot
                          ? Icons.style
                          : (isRune ? Icons.shield_outlined : Icons.auto_awesome),
                      size: 13,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      service.categoryName.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    service.formattedDuration,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Service Title
          Text(
            service.name,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            service.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // Spread Details & Question Badge
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (service.cardCountDescription != null &&
                  service.cardCountDescription!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.obsidianBackground,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.layers_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        service.cardCountDescription!,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: service.questionRequired
                      ? AppColors.sacredPurple.withValues(alpha: 0.15)
                      : AppColors.astralGold.withValues(alpha: 0.12),
                  border: Border.all(
                    color: service.questionRequired
                        ? AppColors.sacredPurple.withValues(alpha: 0.4)
                        : AppColors.astralGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      service.questionRequired
                          ? Icons.help_outline
                          : Icons.auto_awesome,
                      size: 12,
                      color: service.questionRequired
                          ? AppColors.sacredPurple
                          : AppColors.astralGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.questionRequired ? 'Question Required' : 'Open Situational',
                      style: AppTypography.labelSmall.copyWith(
                        color: service.questionRequired
                            ? AppColors.sacredPurple
                            : AppColors.astralGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          // Bottom Row: Price & CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    service.formattedPrice,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.astralGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Details',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.astralGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.astralGold,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
