import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/features/payment/data/payment_repository.dart';
import 'package:tarot_consultation_app/features/payment/domain/payment_state.dart';
import 'package:tarot_consultation_app/models/payment_model.dart';
import 'package:tarot_consultation_app/models/payment_verification_request_model.dart';

final paymentCheckoutProvider = StateNotifierProvider.autoDispose
    .family<PaymentCheckoutNotifier, PaymentCheckoutState, int>((ref, bookingId) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentCheckoutNotifier(repository, bookingId);
});

class PaymentCheckoutNotifier extends StateNotifier<PaymentCheckoutState> {
  final PaymentRepository _repository;
  final int _bookingId;

  PaymentCheckoutNotifier(this._repository, this._bookingId)
      : super(const PaymentCheckoutState()) {
    initiateOrder();
  }

  /// Fetch or initialize payment order from backend with server-locked price
  Future<void> initiateOrder() async {
    state = state.copyWith(isOrderLoading: true, clearError: true);

    try {
      final order = await _repository.createOrder(_bookingId);
      state = state.copyWith(
        order: order,
        isOrderLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isOrderLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectMethod(String method) {
    state = state.copyWith(selectedMethod: method);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Execute verification / checkout transaction
  Future<PaymentModel?> executePayment() async {
    if (state.order == null) {
      state = state.copyWith(errorMessage: 'Payment order has not been initialized.');
      return null;
    }

    state = state.copyWith(isVerifying: true, clearError: true);

    try {
      final request = PaymentVerificationRequestModel(
        transactionId: state.order!.transactionId,
        orderId: state.order!.orderId,
        paymentSignature: 'sig_${DateTime.now().millisecondsSinceEpoch}',
        simulateSuccess: true,
      );

      final payment = await _repository.verifyPayment(request);
      state = state.copyWith(
        isVerifying: false,
        completedPayment: payment,
      );
      return payment;
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}
