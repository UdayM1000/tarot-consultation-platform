import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/payment_model.dart';
import 'package:tarot_consultation_app/models/payment_order_model.dart';
import 'package:tarot_consultation_app/models/payment_verification_request_model.dart';

void main() {
  group('PaymentOrderModel JSON Serialization', () {
    test('should parse backend PaymentOrderResponse correctly', () {
      final json = {
        'orderId': 'order_mock_987654',
        'transactionId': 'txn_mock_123456',
        'amount': 50.00,
        'currency': 'INR',
        'provider': 'MOCK_GATEWAY',
        'bookingReference': 'TR-2026-000101',
        'bookingId': 101,
      };

      final order = PaymentOrderModel.fromJson(json);

      expect(order.orderId, 'order_mock_987654');
      expect(order.transactionId, 'txn_mock_123456');
      expect(order.amount, 50.00);
      expect(order.currency, 'INR');
      expect(order.provider, 'MOCK_GATEWAY');
      expect(order.bookingReference, 'TR-2026-000101');
      expect(order.bookingId, 101);
      expect(order.formattedAmount, '₹ 50.00');

      final backToJson = order.toJson();
      expect(backToJson['orderId'], 'order_mock_987654');
      expect(backToJson['bookingReference'], 'TR-2026-000101');
    });
  });

  group('PaymentVerificationRequestModel JSON Serialization', () {
    test('should serialize verification request properly', () {
      const request = PaymentVerificationRequestModel(
        transactionId: 'txn_mock_123456',
        orderId: 'order_mock_987654',
        paymentSignature: 'sig_test_abc123',
        simulateSuccess: true,
      );

      final json = request.toJson();

      expect(json['transactionId'], 'txn_mock_123456');
      expect(json['orderId'], 'order_mock_987654');
      expect(json['paymentSignature'], 'sig_test_abc123');
      expect(json['simulateSuccess'], isTrue);
    });

    test('should omit empty orderId and signature if not set', () {
      const request = PaymentVerificationRequestModel(
        transactionId: 'txn_mock_123456',
        simulateSuccess: true,
      );

      final json = request.toJson();

      expect(json['transactionId'], 'txn_mock_123456');
      expect(json.containsKey('orderId'), isFalse);
      expect(json.containsKey('paymentSignature'), isFalse);
      expect(json['simulateSuccess'], isTrue);
    });
  });

  group('PaymentModel JSON Serialization', () {
    test('should parse backend PaymentResponse correctly', () {
      final json = {
        'id': 1,
        'bookingId': 101,
        'bookingReference': 'TR-2026-000101',
        'transactionId': 'txn_mock_123456',
        'provider': 'MOCK_GATEWAY',
        'amount': 50.00,
        'currency': 'INR',
        'status': 'SUCCESS',
        'createdAt': '2026-09-19T18:30:00',
        'updatedAt': '2026-09-19T18:30:00',
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.id, 1);
      expect(payment.bookingId, 101);
      expect(payment.bookingReference, 'TR-2026-000101');
      expect(payment.transactionId, 'txn_mock_123456');
      expect(payment.provider, 'MOCK_GATEWAY');
      expect(payment.amount, 50.00);
      expect(payment.currency, 'INR');
      expect(payment.status, 'SUCCESS');
      expect(payment.isSuccess, isTrue);
      expect(payment.isFailed, isFalse);
      expect(payment.formattedAmount, '₹ 50.00');
    });
  });
}
