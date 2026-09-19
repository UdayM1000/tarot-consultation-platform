import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/error_banner.dart';
import 'package:tarot_consultation_app/core/widgets/loading_indicator.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_background.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_button.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/presentation/controllers/reading_controller.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/presentation/widgets/rune_cast_view.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/presentation/widgets/tarot_card_spread_view.dart';
import 'package:tarot_consultation_app/features/reviews/presentation/widgets/review_submission_dialog.dart';
import 'package:tarot_consultation_app/models/reading_result_model.dart';

class ReadingDetailScreen extends ConsumerWidget {
  final int readingId;

  const ReadingDetailScreen({super.key, required this.readingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingDetailProvider(readingId));
    final notifier = ref.read(readingDetailProvider(readingId).notifier);

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.astralGold),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.myReadings);
                    }
                  },
                ),
                title: Text(
                  'Reading Dossier',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.astralGold),
                    onPressed: () => notifier.refresh(),
                  ),
                ],
              ),

              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ErrorBanner(
                    message: state.errorMessage!,
                    onDismiss: () => notifier.refresh(),
                  ),
                ),

              if (state.isLoading)
                const Expanded(
                  child: Center(
                    child: LoadingIndicator(message: 'Opening sacred reading dossier...'),
                  ),
                )
              else if (state.reading != null)
                Expanded(
                  child: _buildReadingContent(context, state.reading!),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        const Text('Reading dossier not found', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        MysticButton(
                          text: 'Reload Dossier',
                          width: 170,
                          onPressed: () => notifier.refresh(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingContent(BuildContext context, ReadingResultModel reading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          _buildDossierHeader(reading),
          const SizedBox(height: 16),

          // Executive Synthesis: Summary & Advice
          _buildSynthesisCard(reading),
          const SizedBox(height: 16),

          // Tarot Cards Section
          if (reading.hasTarotCards) ...[
            TarotCardSpreadView(cards: reading.tarotCards),
            const SizedBox(height: 16),
          ],

          // Rune Cast Section
          if (reading.hasRuneReadings) ...[
            RuneCastView(runes: reading.runeReadings),
            const SizedBox(height: 16),
          ],

          // Concluding Guidance & Reader Notes
          if (reading.additionalNotes != null && reading.additionalNotes!.isNotEmpty) ...[
            _buildNotesCard(reading),
            const SizedBox(height: 24),
          ],

          // Review & Return Action Buttons
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.astralGold,
              side: const BorderSide(color: AppColors.astralGold),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.star_outline, color: AppColors.astralGold),
            label: const Text(
              'Rate Consultation & Leave Review',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () => ReviewSubmissionDialog.show(
              context,
              bookingId: reading.bookingId,
              serviceName: reading.serviceName,
            ),
          ),
          const SizedBox(height: 12),
          MysticButton(
            text: 'Return to Reading Journal',
            icon: Icons.book,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.myReadings);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDossierHeader(ReadingResultModel reading) {
    return MysticCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reading.bookingReference,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.astralGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.sacredPurple.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'COMPLETED',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.sacredPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reading.serviceName,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_available, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Recorded on ${reading.formattedDateTime}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesisCard(ReadingResultModel reading) {
    return MysticCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Spiritual Synthesis',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Summary
          Text(
            'CONSULTATION SUMMARY',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.astralGold,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reading.summary,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 14),

          // Advice
          Text(
            'INTUITIVE ADVICE & GUIDANCE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.sacredPurple,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reading.advice,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // Outcome if present
          if (reading.outcome != null && reading.outcome!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 14),
            Text(
              'FORECASTED OUTCOME',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.astralGold,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reading.outcome!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(ReadingResultModel reading) {
    return MysticCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                'Reader Reflection Notes',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reading.additionalNotes!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
