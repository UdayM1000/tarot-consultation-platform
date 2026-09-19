import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/mystic_background.dart';
import '../../../../core/widgets/mystic_button.dart';
import '../../../../core/widgets/mystic_card.dart';
import '../controllers/payment_controller.dart';

class PaymentCheckoutScreen extends ConsumerWidget {
  final int bookingId;

  const PaymentCheckoutScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(paymentCheckoutProvider(bookingId));
    final checkoutNotifier = ref.read(paymentCheckoutProvider(bookingId).notifier);

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: checkoutState.isOrderLoading
              ? const Center(
                  child: LoadingIndicator(message: 'Securing consultation price lock...'),
                )
              : checkoutState.order == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to initiate payment',
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              checkoutState.errorMessage ?? 'Could not create payment order.',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            MysticButton(
                              text: 'Retry',
                              width: 140,
                              onPressed: () => checkoutNotifier.initiateOrder(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
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
                            'Secure Checkout',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                          ),
                        ),

                        // Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Booking Summary Card
                                MysticCard(
                                  padding: const EdgeInsets.all(18),
                                  borderColor: AppColors.astralGold.withValues(alpha: 0.4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Consultation Booking',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color: AppColors.astralGold.withValues(alpha: 0.15),
                                              border: Border.all(
                                                color: AppColors.astralGold.withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.lock_outline,
                                                  size: 11,
                                                  color: AppColors.astralGold,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Price Locked',
                                                  style: TextStyle(
                                                    color: AppColors.astralGold,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        checkoutState.order!.bookingReference,
                                        style: AppTypography.titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, color: AppColors.cardBorder),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Amount Due',
                                            style: AppTypography.bodyMedium,
                                          ),
                                          Text(
                                            checkoutState.order!.formattedAmount,
                                            style: AppTypography.headlineSmall.copyWith(
                                              color: AppColors.astralGold,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Payment Method Selection
                                const Text(
                                  'Select Payment Method',
                                  style: AppTypography.titleSmall,
                                ),
                                const SizedBox(height: 10),

                                _PaymentMethodTile(
                                  title: 'Instant UPI / QR Code',
                                  subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
                                  icon: Icons.qr_code_2,
                                  isSelected: checkoutState.selectedMethod == 'UPI',
                                  onTap: () => checkoutNotifier.selectMethod('UPI'),
                                ),
                                const SizedBox(height: 10),

                                _PaymentMethodTile(
                                  title: 'Debit / Credit Cards',
                                  subtitle: 'Visa, MasterCard, RuPay',
                                  icon: Icons.credit_card,
                                  isSelected: checkoutState.selectedMethod == 'CARD',
                                  onTap: () => checkoutNotifier.selectMethod('CARD'),
                                ),
                                const SizedBox(height: 10),

                                _PaymentMethodTile(
                                  title: 'NetBanking & Wallets',
                                  subtitle: 'All major Indian retail banks',
                                  icon: Icons.account_balance,
                                  isSelected: checkoutState.selectedMethod == 'NETBANKING',
                                  onTap: () => checkoutNotifier.selectMethod('NETBANKING'),
                                ),
                                const SizedBox(height: 10),

                                _PaymentMethodTile(
                                  title: 'Test Gateway Provider',
                                  subtitle: 'Instant sandbox verification',
                                  icon: Icons.science_outlined,
                                  isSelected: checkoutState.selectedMethod == 'MOCK',
                                  onTap: () => checkoutNotifier.selectMethod('MOCK'),
                                ),
                                const SizedBox(height: 24),

                                // Security Badge Card
                                MysticCard(
                                  padding: const EdgeInsets.all(14),
                                  borderColor: AppColors.cardBorder,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user,
                                        color: AppColors.success,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'End-to-End Secure Transaction',
                                              style: AppTypography.labelLarge.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '256-bit SSL encrypted • Server-side signature verified',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Error Banner if payment failed
                                if (checkoutState.errorMessage != null) ...[
                                  ErrorBanner(
                                    message: checkoutState.errorMessage!,
                                    onDismiss: () => checkoutNotifier.clearError(),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),

                        // Sticky Bottom Pay Bar
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
                                      'Amount to Pay',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Text(
                                      checkoutState.order!.formattedAmount,
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
                                    text: 'Pay & Confirm Booking',
                                    isLoading: checkoutState.isVerifying,
                                    onPressed: () => _handlePay(context, checkoutNotifier),
                                  ),
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

  Future<void> _handlePay(
    BuildContext context,
    PaymentCheckoutNotifier notifier,
  ) async {
    final payment = await notifier.executePayment();
    if (payment != null && context.mounted) {
      context.go(
        AppRoutes.paymentSuccess,
        extra: payment,
      );
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MysticCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: isSelected ? AppColors.astralGold : AppColors.cardBorder,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.astralGold.withValues(alpha: 0.2)
                  : AppColors.midnightSurface,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.astralGold : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.astralGold : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.astralGold : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
