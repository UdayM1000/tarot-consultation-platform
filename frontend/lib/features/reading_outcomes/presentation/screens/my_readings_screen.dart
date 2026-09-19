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
import 'package:tarot_consultation_app/models/reading_result_model.dart';

class MyReadingsScreen extends ConsumerWidget {
  const MyReadingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myReadingsProvider);
    final notifier = ref.read(myReadingsProvider.notifier);

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
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                title: Text(
                  'Reading Journal',
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

              Expanded(
                child: state.isLoading && state.readings.isEmpty
                    ? const Center(child: LoadingIndicator(message: 'Loading your spiritual journal...'))
                    : state.readings.isEmpty
                        ? _buildEmptyJournal(context)
                        : RefreshIndicator(
                            color: AppColors.astralGold,
                            backgroundColor: AppColors.cardSurface,
                            onRefresh: () => notifier.refresh(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: state.readings.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final reading = state.readings[index];
                                return _ReadingJournalCard(reading: reading);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyJournal(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('Your Journal is Quiet', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'You have no completed readings recorded yet. Book a session with a reader to unveil your cards and runes.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            MysticButton(
              text: 'Explore Consultations',
              width: 200,
              onPressed: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingJournalCard extends StatelessWidget {
  final ReadingResultModel reading;

  const _ReadingJournalCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    return MysticCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/reading/${reading.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reading.bookingReference,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.astralGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                reading.formattedDate,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Service Title
          Text(
            reading.serviceName,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Summary Excerpt
          Text(
            reading.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Cards & Runes Count Pill Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (reading.hasTarotCards) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.astralGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.astralGold.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${reading.tarotCards.length} Tarot Cards',
                        style: const TextStyle(fontSize: 11, color: AppColors.astralGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (reading.hasRuneReadings) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.sacredPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.sacredPurple.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${reading.runeReadings.length} Rune Stones',
                        style: const TextStyle(fontSize: 11, color: AppColors.sacredPurple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              const Row(
                children: [
                  Text(
                    'Read Dossier',
                    style: TextStyle(fontSize: 12, color: AppColors.astralGold, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.astralGold),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
