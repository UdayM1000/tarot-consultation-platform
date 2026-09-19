import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/notifications/data/notification_repository.dart';
import 'package:tarot_consultation_app/features/notifications/domain/notification_state.dart';

final notificationCenterProvider =
    StateNotifierProvider<NotificationCenterNotifier, NotificationCenterState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationCenterNotifier(repository);
});

class NotificationCenterNotifier extends StateNotifier<NotificationCenterState> {
  final NotificationRepository _repository;

  NotificationCenterNotifier(this._repository) : super(const NotificationCenterState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load notifications: $e',
      );
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final unreadCount = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: unreadCount);
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    // Optimistic update
    final updatedList = state.notifications.map((n) {
      if (n.id == id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final newCount = (state.unreadCount > 0) ? state.unreadCount - 1 : 0;
    state = state.copyWith(
      notifications: updatedList,
      unreadCount: newCount,
    );

    try {
      await _repository.markAsRead(id);
    } catch (_) {}
  }
}
