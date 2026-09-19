import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/chat_message_model.dart';
import 'package:tarot_consultation_app/models/create_session_request_model.dart';
import 'package:tarot_consultation_app/models/send_chat_message_request_model.dart';
import 'package:tarot_consultation_app/models/session_model.dart';

void main() {
  group('SessionModel Serialization & Helpers', () {
    final sampleJson = {
      'id': 201,
      'bookingId': 101,
      'bookingReference': 'TR-2026-000101',
      'sessionType': 'VIDEO',
      'provider': 'MOCK_VIDEO_PROVIDER',
      'externalSessionId': 'room_abc12345',
      'joinUrl': 'https://consult.tarotplatform.com/rooms/room_abc12345',
      'startedAt': '2026-09-19T18:00:00',
      'endedAt': null,
      'status': 'ACTIVE',
      'createdAt': '2026-09-19T17:50:00',
    };

    test('should parse SessionModel correctly from JSON', () {
      final session = SessionModel.fromJson(sampleJson);

      expect(session.id, 201);
      expect(session.bookingId, 101);
      expect(session.bookingReference, 'TR-2026-000101');
      expect(session.sessionType, 'VIDEO');
      expect(session.provider, 'MOCK_VIDEO_PROVIDER');
      expect(session.externalSessionId, 'room_abc12345');
      expect(session.joinUrl, 'https://consult.tarotplatform.com/rooms/room_abc12345');
      expect(session.status, 'ACTIVE');
      expect(session.isActive, isTrue);
      expect(session.isScheduled, isFalse);
      expect(session.isEnded, isFalse);
      expect(session.canJoin, isTrue);
      expect(session.formattedStatus, 'Live Now');
    });

    test('should serialize SessionModel to JSON', () {
      final session = SessionModel.fromJson(sampleJson);
      final json = session.toJson();

      expect(json['id'], 201);
      expect(json['bookingId'], 101);
      expect(json['bookingReference'], 'TR-2026-000101');
      expect(json['status'], 'ACTIVE');
    });

    test('status helpers work for SCHEDULED and ENDED states', () {
      final scheduled = SessionModel.fromJson({...sampleJson, 'status': 'SCHEDULED'});
      expect(scheduled.isScheduled, isTrue);
      expect(scheduled.isActive, isFalse);
      expect(scheduled.formattedStatus, 'Scheduled');

      final ended = SessionModel.fromJson({...sampleJson, 'status': 'ENDED'});
      expect(ended.isEnded, isTrue);
      expect(ended.canJoin, isFalse);
      expect(ended.formattedStatus, 'Concluded');
    });
  });

  group('ChatMessageModel Serialization & Helpers', () {
    final sampleJson = {
      'id': 501,
      'bookingId': 101,
      'senderId': 2,
      'senderName': 'Master Elysia',
      'message': 'Welcome to your Celtic Cross reading.',
      'messageType': 'TEXT',
      'sentAt': '2026-09-19T18:05:00',
      'readAt': null,
    };

    test('should parse ChatMessageModel correctly from JSON', () {
      final msg = ChatMessageModel.fromJson(sampleJson);

      expect(msg.id, 501);
      expect(msg.bookingId, 101);
      expect(msg.senderId, 2);
      expect(msg.senderName, 'Master Elysia');
      expect(msg.message, 'Welcome to your Celtic Cross reading.');
      expect(msg.messageType, 'TEXT');
      expect(msg.isText, isTrue);
      expect(msg.isSystem, isFalse);
      expect(msg.isCardDraw, isFalse);
      expect(msg.isRead, isFalse);
    });

    test('should detect SYSTEM and CARD_DRAW types', () {
      final systemMsg = ChatMessageModel.fromJson({
        ...sampleJson,
        'messageType': 'SYSTEM',
        'message': 'Session started.',
      });
      expect(systemMsg.isSystem, isTrue);

      final cardMsg = ChatMessageModel.fromJson({
        ...sampleJson,
        'messageType': 'CARD_DRAW',
        'message': 'The High Priestess (Upright)',
      });
      expect(cardMsg.isCardDraw, isTrue);
    });
  });

  group('Request Models Serialization', () {
    test('SendChatMessageRequestModel serialization', () {
      const request = SendChatMessageRequestModel(
        bookingId: 101,
        message: 'I am ready for the reading.',
      );
      final json = request.toJson();

      expect(json['bookingId'], 101);
      expect(json['message'], 'I am ready for the reading.');
      expect(json['messageType'], 'TEXT');
    });

    test('CreateSessionRequestModel serialization', () {
      const request = CreateSessionRequestModel(
        bookingId: 101,
        provider: 'MOCK_VIDEO_PROVIDER',
      );
      final json = request.toJson();

      expect(json['bookingId'], 101);
      expect(json['provider'], 'MOCK_VIDEO_PROVIDER');
    });
  });
}
