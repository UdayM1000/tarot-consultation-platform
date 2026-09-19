class SessionModel {
  final int id;
  final int bookingId;
  final String bookingReference;
  final String sessionType;
  final String provider;
  final String? externalSessionId;
  final String? joinUrl;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String status;
  final DateTime? createdAt;

  const SessionModel({
    required this.id,
    required this.bookingId,
    required this.bookingReference,
    required this.sessionType,
    required this.provider,
    this.externalSessionId,
    this.joinUrl,
    this.startedAt,
    this.endedAt,
    required this.status,
    this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as int? ?? 0,
      bookingReference: json['bookingReference'] as String? ?? '',
      sessionType: json['sessionType'] as String? ?? 'VIDEO',
      provider: json['provider'] as String? ?? 'MOCK_VIDEO_PROVIDER',
      externalSessionId: json['externalSessionId'] as String?,
      joinUrl: json['joinUrl'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.tryParse(json['endedAt'].toString())
          : null,
      status: json['status'] as String? ?? 'SCHEDULED',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'sessionType': sessionType,
      'provider': provider,
      'externalSessionId': externalSessionId,
      'joinUrl': joinUrl,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isScheduled => status.toUpperCase() == 'SCHEDULED';
  bool get isWaiting => status.toUpperCase() == 'WAITING';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isEnded => status.toUpperCase() == 'ENDED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  bool get canJoin => isActive || isScheduled || isWaiting;

  String get formattedStatus {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return 'Scheduled';
      case 'WAITING':
        return 'Waiting to Begin';
      case 'ACTIVE':
        return 'Live Now';
      case 'ENDED':
        return 'Concluded';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
