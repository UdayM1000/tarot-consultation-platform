import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/session/domain/chat_state.dart';
import 'package:tarot_consultation_app/features/session/domain/session_state.dart';
import 'package:tarot_consultation_app/models/chat_message_model.dart';
import 'package:tarot_consultation_app/models/session_model.dart';

void main() {
  group('SessionRoomState Tests', () {
    test('initial state has correct default values', () {
      const state = SessionRoomState(bookingId: 101);

      expect(state.bookingId, 101);
      expect(state.session, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isActionLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.actionSuccessMessage, isNull);
    });

    test('copyWith updates fields correctly', () {
      const state = SessionRoomState(bookingId: 101);

      const session = SessionModel(
        id: 201,
        bookingId: 101,
        bookingReference: 'TR-2026-000101',
        sessionType: 'VIDEO',
        provider: 'MOCK_VIDEO_PROVIDER',
        status: 'ACTIVE',
      );

      final updated = state.copyWith(
        session: () => session,
        isLoading: false,
        actionSuccessMessage: () => 'Session started',
      );

      expect(updated.session, isNotNull);
      expect(updated.session?.status, 'ACTIVE');
      expect(updated.actionSuccessMessage, 'Session started');
    });

    test('copyWith resets error when null function provided', () {
      const state = SessionRoomState(
        bookingId: 101,
        errorMessage: 'Network error',
      );
      expect(state.errorMessage, 'Network error');

      final cleared = state.copyWith(errorMessage: () => null);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('ConsultationChatState Tests', () {
    test('initial state has empty messages and default flags', () {
      const state = ConsultationChatState(bookingId: 101);

      expect(state.bookingId, 101);
      expect(state.messages, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isSending, isFalse);
      expect(state.isPolling, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith appends messages and toggles flags', () {
      const state = ConsultationChatState(bookingId: 101);

      final message = ChatMessageModel(
        id: 1,
        bookingId: 101,
        senderId: 2,
        senderName: 'Master Elysia',
        message: 'Hello seeker',
        messageType: 'TEXT',
        sentAt: DateTime.now(),
      );

      final updated = state.copyWith(
        messages: [message],
        isSending: true,
        isPolling: true,
      );

      expect(updated.messages.length, 1);
      expect(updated.messages.first.message, 'Hello seeker');
      expect(updated.isSending, isTrue);
      expect(updated.isPolling, isTrue);
    });
  });
}
