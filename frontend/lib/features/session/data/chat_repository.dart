import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../models/chat_message_model.dart';
import '../../../models/send_chat_message_request_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepository(apiClient);
});

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  /// Send a consultation chat message
  Future<ChatMessageModel> sendMessage(SendChatMessageRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.chatMessages,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return ChatMessageModel.fromJson(data);
  }

  /// Get consultation messages (paginated, sorted newest first by server)
  Future<List<ChatMessageModel>> getMessages(int bookingId, {int page = 0, int size = 50}) async {
    final response = await _apiClient.get(
      ApiConstants.bookingChatMessages(bookingId),
      queryParameters: {'page': page, 'size': size},
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('content') && map['content'] is List) {
        final list = map['content'] as List;
        return list
            .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (response.data is List) {
      final list = response.data as List;
      return list
          .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Mark incoming reader messages as read
  Future<void> markMessagesRead(int bookingId) async {
    await _apiClient.patch(ApiConstants.markChatRead(bookingId));
  }
}
