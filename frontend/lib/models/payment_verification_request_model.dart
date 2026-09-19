class PaymentVerificationRequestModel {
  final String transactionId;
  final String? orderId;
  final String? paymentSignature;
  final bool simulateSuccess;

  const PaymentVerificationRequestModel({
    required this.transactionId,
    this.orderId,
    this.paymentSignature,
    this.simulateSuccess = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      if (orderId != null && orderId!.isNotEmpty) 'orderId': orderId,
      if (paymentSignature != null && paymentSignature!.isNotEmpty)
        'paymentSignature': paymentSignature,
      'simulateSuccess': simulateSuccess,
    };
  }

  @override
  String toString() =>
      'PaymentVerificationRequestModel(txn: $transactionId, orderId: $orderId, success: $simulateSuccess)';
}
