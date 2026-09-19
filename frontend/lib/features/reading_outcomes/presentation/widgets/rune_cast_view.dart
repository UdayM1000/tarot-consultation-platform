import 'package:flutter/material.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/models/rune_reading_model.dart';

class RuneCastView extends StatelessWidget {
  final List<RuneReadingModel> runes;

  const RuneCastView({super.key, required this.runes});

  @override
  Widget build(BuildContext context) {
    if (runes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle_outlined, color: AppColors.sacredPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Norse Rune Cast (${runes.length})',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: runes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final rune = runes[index];
            return _SingleRuneTile(rune: rune, index: index + 1);
          },
        ),
      ],
    );
  }
}

class _SingleRuneTile extends StatelessWidget {
  final RuneReadingModel rune;
  final int index;

  const _SingleRuneTile({required this.rune, required this.index});

  @override
  Widget build(BuildContext context) {
    return MysticCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.sacredPurple.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position & Rune Index Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sacredPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.5)),
                ),
                child: Text(
                  rune.position.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.sacredPurple,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                'Rune #$index',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rune Visual Stone Tablet & Interpretation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carved Norse Stone Tablet
              Container(
                width: 58,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.obsidianBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sacredPurple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    rune.glyph,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.astralGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Rune Name & Interpretation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rune.runeName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rune.interpretation,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
