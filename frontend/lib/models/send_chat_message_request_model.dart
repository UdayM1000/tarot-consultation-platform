class SendChatMessageRequestModel {
  final int bookingId;
  final String message;
  final String messageType;

  const SendChatMessageRequestModel({
    required this.bookingId,
    required this.message,
    this.messageType = 'TEXT',
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'message': message,
      'messageType': messageType,
    };
  }
}
