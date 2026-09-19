import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../models/payment_model.dart';
import '../../../models/payment_order_model.dart';
import '../../../models/payment_verification_request_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRepository(apiClient);
});

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  /// Initiate a payment order using server-side locked price
  Future<PaymentOrderModel> createOrder(int bookingId) async {
    final response = await _apiClient.post(
      ApiConstants.createPaymentOrder,
      data: {'bookingId': bookingId},
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return PaymentOrderModel.fromJson(data);
  }

  /// Verify payment signature / transaction and confirm booking
  Future<PaymentModel> verifyPayment(PaymentVerificationRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.verifyPayment,
      data: request.toJson(),
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return PaymentModel.fromJson(data);
  }
}
