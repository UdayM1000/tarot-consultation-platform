import '../../../models/payment_model.dart';
import '../../../models/payment_order_model.dart';

class PaymentCheckoutState {
  final PaymentOrderModel? order;
  final String selectedMethod; // 'UPI', 'CARD', 'NETBANKING', 'MOCK'
  final bool isOrderLoading;
  final bool isVerifying;
  final PaymentModel? completedPayment;
  final String? errorMessage;

  const PaymentCheckoutState({
    this.order,
    this.selectedMethod = 'UPI',
    this.isOrderLoading = false,
    this.isVerifying = false,
    this.completedPayment,
    this.errorMessage,
  });

  PaymentCheckoutState copyWith({
    PaymentOrderModel? order,
    String? selectedMethod,
    bool? isOrderLoading,
    bool? isVerifying,
    PaymentModel? completedPayment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentCheckoutState(
      order: order ?? this.order,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isOrderLoading: isOrderLoading ?? this.isOrderLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      completedPayment: completedPayment ?? this.completedPayment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
