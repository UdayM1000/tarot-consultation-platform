import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class BookingModel {
  final int id;
  final String bookingReference;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final int serviceId;
  final String serviceName;
  final String serviceSlug;
  final int durationMinutes;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String sessionType;
  final String? question;
  final String? additionalInformation;
  final double priceAtBooking;
  final String status;
  final bool disclaimerAccepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.bookingReference,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.serviceId,
    required this.serviceName,
    required this.serviceSlug,
    required this.durationMinutes,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.sessionType,
    this.question,
    this.additionalInformation,
    required this.priceAtBooking,
    required this.status,
    required this.disclaimerAccepted,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] as num).toInt(),
      bookingReference: json['bookingReference'] as String? ?? '',
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      serviceId: (json['serviceId'] as num?)?.toInt() ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      serviceSlug: json['serviceSlug'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      scheduledStart: DateTime.parse(json['scheduledStart'].toString()),
      scheduledEnd: DateTime.parse(json['scheduledEnd'].toString()),
      sessionType: json['sessionType'] as String? ?? 'VIDEO',
      question: json['question'] as String?,
      additionalInformation: json['additionalInformation'] as String?,
      priceAtBooking: (json['priceAtBooking'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      disclaimerAccepted: json['disclaimerAccepted'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingReference': bookingReference,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceSlug': serviceSlug,
      'durationMinutes': durationMinutes,
      'scheduledStart': scheduledStart.toIso8601String(),
      'scheduledEnd': scheduledEnd.toIso8601String(),
      'sessionType': sessionType,
      'question': question,
      'additionalInformation': additionalInformation,
      'priceAtBooking': priceAtBooking,
      'status': status,
      'disclaimerAccepted': disclaimerAccepted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedPrice => '${AppConstants.currencySymbol}${priceAtBooking.toStringAsFixed(2)}';

  String get formattedScheduledDate =>
      DateFormat('EEEE, MMM d, yyyy').format(scheduledStart);

  String get formattedScheduledTime =>
      DateFormat('hh:mm a').format(scheduledStart);

  String get formattedScheduledTimeRange =>
      '${DateFormat('hh:mm a').format(scheduledStart)} - ${DateFormat('hh:mm a').format(scheduledEnd)}';

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BookingModel(id: $id, ref: $bookingReference, service: $serviceName, status: $status)';
}
