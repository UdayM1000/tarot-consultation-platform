import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Fetch user notifications ordered chronologically
  Future<List<NotificationModel>> getNotifications({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('content') && map['content'] is List) {
        final list = map['content'] as List;
        return list
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (response.data is List) {
      final list = response.data as List;
      return list
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Mark notification as read
  Future<void> markAsRead(int id) async {
    await _apiClient.patch(ApiConstants.markNotificationRead(id));
  }

  /// Get count of unread notifications for badge display
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiConstants.unreadNotificationCount);
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      return (map['unreadCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}
