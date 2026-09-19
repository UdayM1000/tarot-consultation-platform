class CreateSessionRequestModel {
  final int bookingId;
  final String? provider;

  const CreateSessionRequestModel({
    required this.bookingId,
    this.provider,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
    };
    if (provider != null) {
      map['provider'] = provider;
    }
    return map;
  }
}
