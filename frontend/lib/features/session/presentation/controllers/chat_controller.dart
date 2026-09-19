import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/session/data/chat_repository.dart';
import 'package:tarot_consultation_app/features/session/domain/chat_state.dart';
import 'package:tarot_consultation_app/models/chat_message_model.dart';
import 'package:tarot_consultation_app/models/send_chat_message_request_model.dart';

final consultationChatProvider = StateNotifierProvider.family
    .autoDispose<ConsultationChatNotifier, ConsultationChatState, int>((ref, bookingId) {
  final repository = ref.watch(chatRepositoryProvider);
  return ConsultationChatNotifier(repository, bookingId);
});

class ConsultationChatNotifier extends StateNotifier<ConsultationChatState> {
  final ChatRepository _repository;
  final int _bookingId;
  Timer? _pollingTimer;

  ConsultationChatNotifier(this._repository, this._bookingId)
      : super(ConsultationChatState(bookingId: _bookingId)) {
    loadMessages();
    startPolling();
  }

  /// Start 4-second background synchronization timer for real-time messages
  void startPolling() {
    _pollingTimer?.cancel();
    state = state.copyWith(isPolling: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      loadMessages(isSilent: true);
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
  }

  /// Load consultation messages
  Future<void> loadMessages({bool isSilent = false}) async {
    if (!isSilent) {
      state = state.copyWith(isLoading: true, errorMessage: () => null);
    }
    try {
      final messages = await _repository.getMessages(_bookingId);
      // Backend returns newest first; sort ascending for chat bubble stream
      final sorted = List<ChatMessageModel>.from(messages)
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

      state = state.copyWith(
        messages: sorted,
        isLoading: false,
      );

      // Auto-mark read
      _repository.markMessagesRead(_bookingId).ignore();
    } on ApiException catch (e) {
      if (!isSilent) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => e.message,
        );
      }
    } catch (e) {
      if (!isSilent) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Failed to load chat messages: $e',
        );
      }
    }
  }

  /// Send message in consultation chat
  Future<bool> sendMessage(String text, {String messageType = 'TEXT'}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    state = state.copyWith(isSending: true, errorMessage: () => null);
    try {
      final request = SendChatMessageRequestModel(
        bookingId: _bookingId,
        message: trimmed,
        messageType: messageType,
      );

      final sentMessage = await _repository.sendMessage(request);
      final updatedList = List<ChatMessageModel>.from(state.messages)..add(sentMessage);

      state = state.copyWith(
        messages: updatedList,
        isSending: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: () => e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: () => 'Failed to send message: $e',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
