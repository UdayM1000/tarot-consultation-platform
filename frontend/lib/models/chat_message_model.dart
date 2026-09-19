import 'package:intl/intl.dart';

class ChatMessageModel {
  final int id;
  final int bookingId;
  final int senderId;
  final String senderName;
  final String message;
  final String messageType;
  final DateTime sentAt;
  final DateTime? readAt;

  const ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.messageType,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as int? ?? 0,
      senderId: json['senderId'] as int? ?? 0,
      senderName: json['senderName'] as String? ?? 'Consultant',
      message: json['message'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'TEXT',
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'messageType': messageType,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  bool get isSystem => messageType.toUpperCase() == 'SYSTEM';
  bool get isCardDraw => messageType.toUpperCase() == 'CARD_DRAW';
  bool get isText => messageType.toUpperCase() == 'TEXT';
  bool get isRead => readAt != null;

  String get formattedTime => DateFormat('h:mm a').format(sentAt);
}
