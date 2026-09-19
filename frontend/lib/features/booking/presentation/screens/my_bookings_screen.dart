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
import '../../../../models/booking_model.dart';
import 'package:tarot_consultation_app/features/reviews/presentation/widgets/review_submission_dialog.dart';
import '../controllers/booking_controller.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(myBookingsProvider);
    final bookingsNotifier = ref.read(myBookingsProvider.notifier);

    final allBookings = bookingsState.bookings;
    final upcomingBookings = allBookings
        .where((b) => b.isPending || b.isConfirmed)
        .toList();
    final pastBookings = allBookings
        .where((b) => b.isCompleted || b.isCancelled)
        .toList();

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
                  'My Consultations',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.astralGold),
                    onPressed: () => bookingsNotifier.refresh(),
                  ),
                ],
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.astralGold,
                labelColor: AppColors.astralGold,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'All (${allBookings.length})'),
                  Tab(text: 'Upcoming (${upcomingBookings.length})'),
                  Tab(text: 'Past (${pastBookings.length})'),
                ],
              ),
              const SizedBox(height: 12),

              // Error Banner if any
              if (bookingsState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ErrorBanner(
                    message: bookingsState.errorMessage!,
                    onDismiss: () => bookingsNotifier.refresh(),
                  ),
                ),

              // Tab Bar View Body
              Expanded(
                child: bookingsState.isLoading
                    ? const Center(
                        child: LoadingIndicator(message: 'Loading your consultations...'),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _BookingsList(
                            bookings: allBookings,
                            onRefresh: () => bookingsNotifier.refresh(),
                            onCancel: (id) => _confirmCancel(context, id),
                          ),
                          _BookingsList(
                            bookings: upcomingBookings,
                            onRefresh: () => bookingsNotifier.refresh(),
                            onCancel: (id) => _confirmCancel(context, id),
                          ),
                          _BookingsList(
                            bookings: pastBookings,
                            onRefresh: () => bookingsNotifier.refresh(),
                            onCancel: (id) => _confirmCancel(context, id),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Cancel Consultation?', style: AppTypography.titleMedium),
        content: const Text(
          'Are you sure you want to cancel this consultation? This action cannot be undone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              final success = await ref.read(myBookingsProvider.notifier).cancelBooking(bookingId);
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Consultation cancelled.' : 'Failed to cancel booking.',
                    ),
                    backgroundColor: success ? AppColors.cardSurface : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<BookingModel> bookings;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onCancel;

  const _BookingsList({
    required this.bookings,
    required this.onRefresh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month_outlined, size: 54, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text('No Consultations Found', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'You have no bookings under this section.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              MysticButton(
                text: 'Explore Readings',
                width: 170,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.astralGold,
      backgroundColor: AppColors.cardSurface,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _BookingCard(booking: booking, onCancel: () => onCancel(booking.id));
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;

  const _BookingCard({required this.booking, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    Color statusColor = AppColors.astralGold;
    if (booking.isConfirmed) {
      statusColor = AppColors.success;
    } else if (booking.isCancelled) {
      statusColor = AppColors.error;
    } else if (booking.isCompleted) {
      statusColor = AppColors.sacredPurple;
    }

    return MysticCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Ref code & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingReference,
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
                  color: statusColor.withValues(alpha: 0.15),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  booking.status,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Service Title
          Text(
            booking.serviceName,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Date & Time
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '${booking.formattedScheduledDate} • ${booking.formattedScheduledTimeRange}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Session Mode & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.sessionType} • ${booking.durationMinutes} mins',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              Text(
                booking.formattedPrice,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.astralGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Actions if pending
          if (booking.isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 14, color: AppColors.error),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                  onPressed: onCancel,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.astralGold,
                    foregroundColor: AppColors.obsidianBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  icon: const Icon(Icons.payment, size: 14),
                  label: Text('Pay Now (${booking.formattedPrice})'),
                  onPressed: () => context.push('/payment/checkout/${booking.id}'),
                ),
              ],
            ),
          ] else if (booking.isConfirmed) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  onPressed: onCancel,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.astralGold,
                    foregroundColor: AppColors.obsidianBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  icon: const Icon(Icons.meeting_room, size: 14),
                  label: const Text('Enter Session Room'),
                  onPressed: () => context.push('/session/${booking.id}'),
                ),
              ],
            ),
          ] else if (booking.isCompleted) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textMuted),
                      label: const Text(
                        'Chat',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                      onPressed: () => context.push('/session/${booking.id}/chat'),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.astralGold,
                        side: const BorderSide(color: AppColors.astralGold),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      icon: const Icon(Icons.star_outline, size: 14),
                      label: const Text('Rate'),
                      onPressed: () => ReviewSubmissionDialog.show(
                        context,
                        bookingId: booking.id,
                        serviceName: booking.serviceName,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sacredPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text('View Reading'),
                  onPressed: () => context.push(AppRoutes.myReadings),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
