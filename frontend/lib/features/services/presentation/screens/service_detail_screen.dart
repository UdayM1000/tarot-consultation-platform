import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/mystic_background.dart';
import '../../../../core/widgets/mystic_button.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../../../../models/reading_service_model.dart';
import '../controllers/services_controller.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final int serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));

    return Scaffold(
      body: MysticBackground(
        child: serviceAsync.when(
          loading: () => const Center(
            child: LoadingIndicator(message: 'Consulting celestial records...'),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load reading details',
                    style: AppTypography.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  MysticButton(
                    text: 'Retry',
                    width: 140,
                    onPressed: () => ref.refresh(serviceDetailProvider(serviceId)),
                  ),
                ],
              ),
            ),
          ),
          data: (service) => _ServiceDetailContent(service: service),
        ),
      ),
    );
  }
}

class _ServiceDetailContent extends StatelessWidget {
  final ReadingServiceModel service;

  const _ServiceDetailContent({required this.service});

  @override
  Widget build(BuildContext context) {
    final isTarot = service.categoryName.toUpperCase().contains('TAROT');
    final isRune = service.categoryName.toUpperCase().contains('RUNE');
    final isCombo = service.categoryName.toUpperCase().contains('COMBO');

    Color categoryColor = AppColors.sacredPurple;
    if (isRune) {
      categoryColor = const Color(0xFF4EA8DE);
    } else if (isCombo) {
      categoryColor = AppColors.astralGold;
    }

    return Column(
      children: [
        // Custom App Bar
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.astralGold),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Reading Details',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: AppColors.textMuted),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading saved to your bookmarks.'),
                    backgroundColor: AppColors.cardSurface,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Duration Chips
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: categoryColor.withValues(alpha: 0.15),
                        border: Border.all(color: categoryColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        service.categoryName.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.cardSurface,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.astralGold),
                          const SizedBox(width: 4),
                          Text(
                            service.formattedDuration,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.astralGold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Service Title
                Text(
                  service.name,
                  style: AppTypography.headlineLarge.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 16),

                // Pricing & Duration Key Metrics Card
                MysticCard(
                  padding: const EdgeInsets.all(18),
                  borderColor: AppColors.astralGold.withValues(alpha: 0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricItem(
                        icon: Icons.currency_rupee,
                        title: 'Price (Locked)',
                        value: service.formattedPrice,
                        highlightValue: true,
                      ),
                      Container(height: 38, width: 1, color: AppColors.cardBorder),
                      _MetricItem(
                        icon: Icons.hourglass_bottom,
                        title: 'Duration',
                        value: service.formattedDuration,
                      ),
                      Container(height: 38, width: 1, color: AppColors.cardBorder),
                      _MetricItem(
                        icon: isTarot
                            ? Icons.style
                            : (isRune ? Icons.shield_outlined : Icons.auto_awesome),
                        title: 'Type',
                        value: isTarot ? 'Tarot' : (isRune ? 'Rune' : 'Combo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Spread & Divination Format
                if (service.cardCountDescription != null &&
                    service.cardCountDescription!.isNotEmpty) ...[
                  const Text('Divination Format', style: AppTypography.titleMedium),
                  const SizedBox(height: 8),
                  MysticCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sacredPurple.withValues(alpha: 0.18),
                          ),
                          child: const Icon(
                            Icons.layers_outlined,
                            size: 20,
                            color: AppColors.sacredPurple,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spread / Casting Configuration',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.cardCountDescription!,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Question Guidance Section
                const Text('Consultation Guidance', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                MysticCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            service.questionRequired ? Icons.help_outline : Icons.auto_awesome,
                            size: 18,
                            color: service.questionRequired
                                ? AppColors.sacredPurple
                                : AppColors.astralGold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            service.questionRequired
                                ? 'Specific Question Required'
                                : 'Open Situational Reading',
                            style: AppTypography.titleSmall.copyWith(
                              color: service.questionRequired
                                  ? AppColors.sacredPurple
                                  : AppColors.astralGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.questionRequired
                          ? 'This consultation requires 1 focused question submitted during booking. Formulate a clear situation or decision for the reader to channel.'
                          : 'No specific question is required. The reader draws cards and casts runes to reveal prevailing energies, subconscious influences, and forward guidance.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                const Text('About This Reading', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                MysticCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    service.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ethics & Disclaimers
                MysticCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppColors.cardBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.astralGold),
                          const SizedBox(width: 8),
                          Text(
                            'Platform Code of Ethics',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.astralGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Readings are for guidance & reflection only.\n• Strictly no medical, legal, or pregnancy inquiries.\n• All reader communications and outcomes remain completely confidential.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for sticky bottom bar
              ],
            ),
          ),
        ),

        // Bottom Sticky Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            border: const Border(top: BorderSide(color: AppColors.cardBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
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
                const SizedBox(width: 20),
                Expanded(
                  child: MysticButton(
                    text: 'Select & Book Reading',
                    onPressed: () => _handleProceedToBook(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleProceedToBook(BuildContext context) {
    context.push('/service/${service.id}/book');
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlightValue;

  const _MetricItem({
    required this.icon,
    required this.title,
    required this.value,
    this.highlightValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: highlightValue ? AppColors.astralGold : AppColors.textMuted),
        const SizedBox(height: 4),
        Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: highlightValue ? AppColors.astralGold : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
