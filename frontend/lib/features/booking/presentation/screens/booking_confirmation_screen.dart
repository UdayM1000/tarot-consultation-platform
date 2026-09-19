import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mystic_background.dart';
import '../../../../core/widgets/mystic_button.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../../../../models/booking_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Celestial Success Emblem
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldButtonGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.astralGold.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 44,
                      color: AppColors.obsidianBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Headline
                const Text(
                  'Consultation Slot Reserved',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your consultation has been created and your time slot is locked.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Reference Code Box
                MysticCard(
                  padding: const EdgeInsets.all(18),
                  borderColor: AppColors.astralGold.withValues(alpha: 0.5),
                  child: Column(
                    children: [
                      Text(
                        'BOOKING REFERENCE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            booking.bookingReference,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.astralGold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18, color: AppColors.astralGold),
                            tooltip: 'Copy Reference',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: booking.bookingReference));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reference copied to clipboard!'),
                                  backgroundColor: AppColors.cardSurface,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Consultation Details Card
                MysticCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.style,
                        label: 'Reading Service',
                        value: booking.serviceName,
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Scheduled Date',
                        value: booking.formattedScheduledDate,
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Time Window',
                        value: booking.formattedScheduledTimeRange,
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: _getSessionIcon(booking.sessionType),
                        label: 'Session Mode',
                        value: '${booking.sessionType} Consultation',
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: Icons.hourglass_empty,
                        label: 'Duration',
                        value: '${booking.durationMinutes} Minutes',
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: Icons.currency_rupee,
                        label: 'Locked Price',
                        value: booking.formattedPrice,
                        isHighlight: true,
                      ),
                      const Divider(height: 24, color: AppColors.cardBorder),
                      _DetailRow(
                        icon: Icons.pending_actions,
                        label: 'Status',
                        value: booking.status,
                        statusBadge: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Next Step Notice
                MysticCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: AppColors.astralGold.withValues(alpha: 0.4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.payment, color: AppColors.astralGold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Payment to Confirm',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.astralGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your slot is held in pending status. Complete your payment of ${booking.formattedPrice} to confirm your consultation.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action CTAs
                MysticButton(
                  text: 'Proceed to Payment (${booking.formattedPrice})',
                  onPressed: () => context.push('/payment/checkout/${booking.id}'),
                ),
                const SizedBox(height: 12),
                MysticButton(
                  text: 'View My Bookings',
                  isOutlined: true,
                  onPressed: () => context.go(AppRoutes.myBookings),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(
                    'Return to Discovery Hub',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSessionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'AUDIO':
        return Icons.phone_in_talk_outlined;
      case 'CHAT':
        return Icons.chat_bubble_outline;
      case 'VIDEO':
      default:
        return Icons.videocam_outlined;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;
  final bool statusBadge;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.statusBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isHighlight ? AppColors.astralGold : AppColors.textMuted),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
        const Spacer(),
        if (statusBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.astralGold.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.astralGold.withValues(alpha: 0.4)),
            ),
            child: Text(
              value,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.astralGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isHighlight ? AppColors.astralGold : AppColors.textPrimary,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
