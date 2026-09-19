class CreateBookingRequestModel {
  final int serviceId;
  final DateTime scheduledStart;
  final String sessionType;
  final String? question;
  final String? additionalInformation;
  final bool disclaimerAccepted;

  const CreateBookingRequestModel({
    required this.serviceId,
    required this.scheduledStart,
    this.sessionType = 'VIDEO',
    this.question,
    this.additionalInformation,
    required this.disclaimerAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'scheduledStart': scheduledStart.toIso8601String(),
      'sessionType': sessionType,
      if (question != null && question!.trim().isNotEmpty)
        'question': question!.trim(),
      if (additionalInformation != null && additionalInformation!.trim().isNotEmpty)
        'additionalInformation': additionalInformation!.trim(),
      'disclaimerAccepted': disclaimerAccepted,
    };
  }

  @override
  String toString() =>
      'CreateBookingRequestModel(serviceId: $serviceId, start: $scheduledStart, type: $sessionType)';
}
