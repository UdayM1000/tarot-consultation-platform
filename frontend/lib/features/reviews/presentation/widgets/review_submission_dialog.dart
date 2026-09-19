import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/error_banner.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_button.dart';
import 'package:tarot_consultation_app/features/reviews/presentation/controllers/review_controller.dart';

class ReviewSubmissionDialog extends ConsumerStatefulWidget {
  final int bookingId;
  final String serviceName;

  const ReviewSubmissionDialog({
    super.key,
    required this.bookingId,
    required this.serviceName,
  });

  static Future<bool?> show(BuildContext context, {required int bookingId, required String serviceName}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReviewSubmissionDialog(
        bookingId: bookingId,
        serviceName: serviceName,
      ),
    );
  }

  @override
  ConsumerState<ReviewSubmissionDialog> createState() => _ReviewSubmissionDialogState();
}

class _ReviewSubmissionDialogState extends ConsumerState<ReviewSubmissionDialog> {
  final TextEditingController _commentController = TextEditingController();

  final List<String> _ratingLabels = [
    '1 - Needs Clarity',
    '2 - Fair Guidance',
    '3 - Insightful',
    '4 - Very Illuminating',
    '5 - Truly Transcendent',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(submitReviewProvider(widget.bookingId));
    final notifier = ref.read(submitReviewProvider(widget.bookingId).notifier);

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (state.isSubmitted) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Review Blessed & Submitted!', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Thank you for sharing your journey. Your reflection honors the reader and guides fellow seekers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            MysticButton(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.astralGold.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.rate_review_outlined, color: AppColors.astralGold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate Consultation',
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        widget.serviceName,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state.errorMessage != null) ...[
              ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],

            // Star Rating Picker
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isSelected = starIndex <= state.rating;
                  return IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? AppColors.astralGold : AppColors.textMuted,
                    ),
                    onPressed: () => notifier.setRating(starIndex),
                  );
                }),
              ),
            ),
            Center(
              child: Text(
                _ratingLabels[state.rating - 1],
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.astralGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Comment text area
            Text(
              'YOUR REFLECTION & EXPERIENCE',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onChanged: (val) => notifier.setComment(val),
              decoration: InputDecoration(
                hintText: 'Describe how the reader\'s insights and cards resonated with your situation...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.obsidianBackground,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.astralGold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            MysticButton(
              text: 'Submit Sacred Review',
              icon: Icons.send_rounded,
              isLoading: state.isSubmitting,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final review = await notifier.submitReview();
                if (review != null && mounted) {
                  // Wait briefly before pop so user sees success
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) {
                    navigator.pop(true);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
