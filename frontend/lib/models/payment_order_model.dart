import '../core/constants/app_constants.dart';

class PaymentOrderModel {
  final String orderId;
  final String transactionId;
  final double amount;
  final String currency;
  final String provider;
  final String bookingReference;
  final int bookingId;

  const PaymentOrderModel({
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.bookingReference,
    required this.bookingId,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: json['orderId'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      provider: json['provider'] as String? ?? 'MOCK_GATEWAY',
      bookingReference: json['bookingReference'] as String? ?? '',
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'provider': provider,
      'bookingReference': bookingReference,
      'bookingId': bookingId,
    };
  }

  String get formattedAmount =>
      '${currency == 'INR' ? AppConstants.currencySymbol : currency} ${amount.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentOrderModel &&
          runtimeType == other.runtimeType &&
          transactionId == other.transactionId &&
          orderId == other.orderId;

  @override
  int get hashCode => transactionId.hashCode ^ orderId.hashCode;

  @override
  String toString() =>
      'PaymentOrderModel(orderId: $orderId, txn: $transactionId, amount: $amount, ref: $bookingReference)';
}
