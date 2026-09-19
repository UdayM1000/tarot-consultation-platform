import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../models/booking_model.dart';
import '../../../models/create_booking_request_model.dart';
import '../../../models/page_response.dart';
import '../../../models/time_slot_model.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient);
});

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  /// Fetch dynamic conflict-free time slots for a service on a given date
  Future<List<TimeSlotModel>> getAvailableSlots(int serviceId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await _apiClient.get(
      ApiConstants.availability,
      queryParameters: {
        'serviceId': serviceId,
        'date': formattedDate,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => TimeSlotModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Create a consultation booking with server-side price lock
  Future<BookingModel> createBooking(CreateBookingRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.bookings,
      data: request.toJson(),
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }

  /// Retrieve paginated consultation bookings for current customer
  Future<PageResponse<BookingModel>> getMyBookings({
    int page = 0,
    int size = 20,
    String sortBy = 'scheduledStart',
    String sortDir = 'desc',
  }) async {
    final response = await _apiClient.get(
      ApiConstants.bookings,
      queryParameters: {
        'page': page,
        'size': size,
        'sort': '$sortBy,$sortDir',
      },
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return PageResponse<BookingModel>.fromJson(
      data,
      (itemJson) => BookingModel.fromJson(itemJson),
    );
  }

  /// Retrieve single booking details
  Future<BookingModel> getBookingById(int id) async {
    final response = await _apiClient.get('${ApiConstants.bookings}/$id');
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }

  /// Cancel an upcoming booking
  Future<BookingModel> cancelBooking(int id) async {
    final response = await _apiClient.put(ApiConstants.cancelBooking(id));
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return BookingModel.fromJson(data);
  }
}
