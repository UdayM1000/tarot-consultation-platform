import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tarot_consultation_app/core/routing/app_routes.dart';
import 'package:tarot_consultation_app/core/theme/app_colors.dart';
import 'package:tarot_consultation_app/core/theme/app_typography.dart';
import 'package:tarot_consultation_app/core/widgets/error_banner.dart';
import 'package:tarot_consultation_app/core/widgets/loading_indicator.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_background.dart';
import 'package:tarot_consultation_app/core/widgets/mystic_card.dart';
import 'package:tarot_consultation_app/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:tarot_consultation_app/models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationCenterProvider);
    final notifier = ref.read(notificationCenterProvider.notifier);

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
                  'Notifications',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.astralGold),
                    onPressed: () => notifier.loadNotifications(),
                  ),
                ],
              ),

              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ErrorBanner(
                    message: state.errorMessage!,
                    onDismiss: () => notifier.loadNotifications(),
                  ),
                ),

              Expanded(
                child: state.isLoading && state.notifications.isEmpty
                    ? const Center(child: LoadingIndicator(message: 'Loading notifications...'))
                    : state.notifications.isEmpty
                        ? _buildEmptyNotifications()
                        : RefreshIndicator(
                            color: AppColors.astralGold,
                            backgroundColor: AppColors.cardSurface,
                            onRefresh: () => notifier.loadNotifications(),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: state.notifications.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final notification = state.notifications[index];
                                return _NotificationCard(
                                  notification: notification,
                                  onTap: () {
                                    notifier.markAsRead(notification.id);
                                    _handleNotificationTap(context, notification);
                                  },
                                );
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

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    switch (notification.type.toUpperCase()) {
      case 'READING_COMPLETED':
        context.push(AppRoutes.myReadings);
        break;
      case 'BOOKING_CONFIRMED':
      case 'SESSION_STARTING':
      case 'SESSION_REMINDER':
      case 'NEW_MESSAGE':
        context.push(AppRoutes.myBookings);
        break;
      default:
        break;
    }
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text('No Notifications Yet', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'You are all caught up. Updates on consultation bookings, reading results, and messages will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = notification.typeColor;
    final isUnread = !notification.isRead;

    return MysticCard(
      padding: const EdgeInsets.all(16),
      borderColor: isUnread ? AppColors.astralGold.withValues(alpha: 0.5) : AppColors.cardBorder,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: typeColor.withValues(alpha: 0.15),
              border: Border.all(color: typeColor.withValues(alpha: 0.4)),
            ),
            child: Icon(notification.typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.astralGold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: isUnread ? AppColors.textSecondary : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.formattedTime,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
