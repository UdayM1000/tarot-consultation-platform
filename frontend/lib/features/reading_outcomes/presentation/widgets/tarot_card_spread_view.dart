import 'package:flutter/material.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/models/tarot_card_reading_model.dart';

class TarotCardSpreadView extends StatelessWidget {
  final List<TarotCardReadingModel> cards;

  const TarotCardSpreadView({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.style, color: AppColors.astralGold, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tarot Spread Cards (${cards.length})',
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
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final card = cards[index];
            return _SingleTarotCardTile(card: card, index: index + 1);
          },
        ),
      ],
    );
  }
}

class _SingleTarotCardTile extends StatelessWidget {
  final TarotCardReadingModel card;
  final int index;

  const _SingleTarotCardTile({required this.card, required this.index});

  @override
  Widget build(BuildContext context) {
    return MysticCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.astralGold.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position & Card Index Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.astralGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.astralGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  card.position.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.astralGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                'Card #$index',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card Visual Presentation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stylized Tarot Card Silhouette
              Container(
                width: 58,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.obsidianBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.astralGold.withValues(alpha: 0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.astralGold.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      'TAROT',
                      style: TextStyle(
                        color: AppColors.astralGold.withValues(alpha: 0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Card Title & Interpretation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      card.interpretation,
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
