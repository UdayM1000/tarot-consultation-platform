import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/features/booking/data/booking_repository.dart';
import 'package:tarot_consultation_app/features/booking/domain/booking_state.dart';
import 'package:tarot_consultation_app/models/booking_model.dart';
import 'package:tarot_consultation_app/models/create_booking_request_model.dart';
import 'package:tarot_consultation_app/models/time_slot_model.dart';

final bookingCreationProvider = StateNotifierProvider.autoDispose
    .family<BookingCreationNotifier, BookingCreationState, int>((ref, serviceId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingCreationNotifier(repository, serviceId);
});

final myBookingsProvider =
    StateNotifierProvider<MyBookingsNotifier, MyBookingsState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return MyBookingsNotifier(repository);
});

class BookingCreationNotifier extends StateNotifier<BookingCreationState> {
  final BookingRepository _repository;
  final int _serviceId;

  BookingCreationNotifier(this._repository, this._serviceId)
      : super(BookingCreationState()) {
    loadSlots(state.selectedDate);
  }

  /// Load available time slots for the selected date
  Future<void> loadSlots(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      clearSlot: true,
      isSlotsLoading: true,
      clearError: true,
    );

    try {
      final slots = await _repository.getAvailableSlots(_serviceId, date);
      state = state.copyWith(
        slots: slots,
        isSlotsLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSlotsLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectSlot(TimeSlotModel slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void selectSessionType(String type) {
    state = state.copyWith(selectedSessionType: type);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Submit the booking request
  Future<BookingModel?> submitBooking({
    required String? question,
    required String? additionalInformation,
    required bool disclaimerAccepted,
  }) async {
    if (state.selectedSlot == null) {
      state = state.copyWith(errorMessage: 'Please select a consultation time slot.');
      return null;
    }

    if (!disclaimerAccepted) {
      state = state.copyWith(
        errorMessage: 'Please accept the consultation platform ethics & disclaimer.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      // Parse slot start time (HH:mm) and combine with selectedDate
      final timeParts = state.selectedSlot!.startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledStart = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day,
        hour,
        minute,
      );

      final request = CreateBookingRequestModel(
        serviceId: _serviceId,
        scheduledStart: scheduledStart,
        sessionType: state.selectedSessionType,
        question: question,
        additionalInformation: additionalInformation,
        disclaimerAccepted: disclaimerAccepted,
      );

      final booking = await _repository.createBooking(request);
      state = state.copyWith(
        isSubmitting: false,
        createdBooking: booking,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}

class MyBookingsNotifier extends StateNotifier<MyBookingsState> {
  final BookingRepository _repository;

  MyBookingsNotifier(this._repository) : super(const MyBookingsState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pageResponse = await _repository.getMyBookings(page: 0);
      state = state.copyWith(
        bookings: pageResponse.content,
        currentPage: 0,
        hasMore: pageResponse.hasNext,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final pageResponse = await _repository.getMyBookings(page: 0);
      state = state.copyWith(
        bookings: pageResponse.content,
        currentPage: 0,
        hasMore: pageResponse.hasNext,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> cancelBooking(int id) async {
    try {
      final updated = await _repository.cancelBooking(id);
      final updatedList = state.bookings.map((b) => b.id == id ? updated : b).toList();
      state = state.copyWith(bookings: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
