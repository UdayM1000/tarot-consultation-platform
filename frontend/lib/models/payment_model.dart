import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class PaymentModel {
  final int id;
  final int bookingId;
  final String bookingReference;
  final String transactionId;
  final String provider;
  final double amount;
  final String currency;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.bookingReference,
    required this.transactionId,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (json['id'] as num).toInt(),
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      bookingReference: json['bookingReference'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      provider: json['provider'] as String? ?? 'MOCK_GATEWAY',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'INITIATED',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'bookingReference': bookingReference,
      'transactionId': transactionId,
      'provider': provider,
      'amount': amount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedAmount =>
      '${currency == 'INR' ? AppConstants.currencySymbol : currency} ${amount.toStringAsFixed(2)}';

  String get formattedDate => createdAt != null
      ? DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(createdAt!)
      : '';

  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          transactionId == other.transactionId;

  @override
  int get hashCode => id.hashCode ^ transactionId.hashCode;

  @override
  String toString() =>
      'PaymentModel(id: $id, txn: $transactionId, amount: $amount, status: $status)';
}
