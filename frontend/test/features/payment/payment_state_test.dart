import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/payment/domain/payment_state.dart';
import 'package:tarot_consultation_app/models/payment_model.dart';
import 'package:tarot_consultation_app/models/payment_order_model.dart';

void main() {
  group('PaymentCheckoutState Tests', () {
    test('initial state should default to UPI method and null order', () {
      const state = PaymentCheckoutState();

      expect(state.selectedMethod, 'UPI');
      expect(state.order, isNull);
      expect(state.isOrderLoading, isFalse);
      expect(state.isVerifying, isFalse);
      expect(state.completedPayment, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith should update payment method and order correctly', () {
      const state = PaymentCheckoutState();
      const order = PaymentOrderModel(
        orderId: 'order_123',
        transactionId: 'txn_123',
        amount: 80.0,
        currency: 'INR',
        provider: 'MOCK_GATEWAY',
        bookingReference: 'TR-2026-000002',
        bookingId: 2,
      );

      final updated = state.copyWith(
        order: order,
        selectedMethod: 'CARD',
        isVerifying: true,
      );

      expect(updated.order, order);
      expect(updated.selectedMethod, 'CARD');
      expect(updated.isVerifying, isTrue);
      expect(updated.order!.amount, 80.0);
    });

    test('copyWith completedPayment should store verified payment', () {
      const state = PaymentCheckoutState();
      const payment = PaymentModel(
        id: 1,
        bookingId: 2,
        bookingReference: 'TR-2026-000002',
        transactionId: 'txn_123',
        provider: 'MOCK_GATEWAY',
        amount: 80.0,
        currency: 'INR',
        status: 'SUCCESS',
      );

      final updated = state.copyWith(
        completedPayment: payment,
        isVerifying: false,
      );

      expect(updated.completedPayment, payment);
      expect(updated.completedPayment!.isSuccess, isTrue);
      expect(updated.isVerifying, isFalse);
    });

    test('clearError should reset errorMessage', () {
      final state = const PaymentCheckoutState().copyWith(errorMessage: 'Payment rejected');
      expect(state.errorMessage, 'Payment rejected');

      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });
}
