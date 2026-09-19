import '../../../models/chat_message_model.dart';

class ConsultationChatState {
  final int bookingId;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final bool isPolling;

  const ConsultationChatState({
    required this.bookingId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.isPolling = false,
  });

  ConsultationChatState copyWith({
    int? bookingId,
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? Function()? errorMessage,
    bool? isPolling,
  }) {
    return ConsultationChatState(
      bookingId: bookingId ?? this.bookingId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}
