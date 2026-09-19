import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mystic_background.dart';
import '../../../../core/widgets/mystic_button.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../../../../models/payment_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentModel payment;

  const PaymentSuccessScreen({super.key, required this.payment});

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

                // Success Emblem
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
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
                      Icons.verified,
                      size: 48,
                      color: AppColors.obsidianBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Payment Confirmed!',
                  style: AppTypography.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your consultation booking is locked and officially confirmed.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Digital Payment Receipt Card
                MysticCard(
                  padding: const EdgeInsets.all(20),
                  borderColor: AppColors.success.withValues(alpha: 0.5),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'OFFICIAL RECEIPT',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppColors.success.withValues(alpha: 0.15),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'CONFIRMED',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Amount Paid Highlight
                      Center(
                        child: Text(
                          payment.formattedAmount,
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.astralGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.cardBorder),
                      const SizedBox(height: 14),

                      _ReceiptRow(
                        label: 'Booking Reference',
                        value: payment.bookingReference,
                        copyable: true,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _ReceiptRow(
                        label: 'Transaction ID',
                        value: payment.transactionId,
                        copyable: true,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _ReceiptRow(
                        label: 'Provider Gateway',
                        value: payment.provider,
                      ),
                      if (payment.formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _ReceiptRow(
                          label: 'Payment Timestamp',
                          value: payment.formattedDate,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Preparation Guidance Card
                MysticCard(
                  padding: const EdgeInsets.all(18),
                  borderColor: AppColors.astralGold.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.astralGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Consultation Preparation',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.astralGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Your reader Astrid has received your consultation booking and questions.\n• Find a calm, reflective space prior to your session.\n• Your live session room link will become accessible 10 minutes prior to scheduled start.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // CTAs
                MysticButton(
                  text: 'Enter Consultation Room',
                  icon: Icons.meeting_room,
                  onPressed: () => context.push('/session/${payment.bookingId}'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.astralGold,
                    side: const BorderSide(color: AppColors.astralGold),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => context.go(AppRoutes.myBookings),
                  child: const Text(
                    'View My Consultations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 12),
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
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final BuildContext? context;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (copyable) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  if (this.context != null) {
                    ScaffoldMessenger.of(this.context!).showSnackBar(
                      SnackBar(
                        content: Text('$label copied to clipboard!'),
                        backgroundColor: AppColors.cardSurface,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.copy, size: 14, color: AppColors.astralGold),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
