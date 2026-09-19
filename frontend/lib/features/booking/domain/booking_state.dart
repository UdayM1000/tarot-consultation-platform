import '../../../models/booking_model.dart';
import '../../../models/time_slot_model.dart';

class BookingCreationState {
  final DateTime selectedDate;
  final TimeSlotModel? selectedSlot;
  final String selectedSessionType;
  final List<TimeSlotModel> slots;
  final bool isSlotsLoading;
  final bool isSubmitting;
  final BookingModel? createdBooking;
  final String? errorMessage;

  BookingCreationState({
    DateTime? selectedDate,
    this.selectedSlot,
    this.selectedSessionType = 'VIDEO',
    this.slots = const [],
    this.isSlotsLoading = false,
    this.isSubmitting = false,
    this.createdBooking,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? _initialDate();

  static DateTime _initialDate() {
    final now = DateTime.now();
    // Default to tomorrow so consultations are comfortably in the future
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  BookingCreationState copyWith({
    DateTime? selectedDate,
    TimeSlotModel? selectedSlot,
    bool clearSlot = false,
    String? selectedSessionType,
    List<TimeSlotModel>? slots,
    bool? isSlotsLoading,
    bool? isSubmitting,
    BookingModel? createdBooking,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingCreationState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      selectedSessionType: selectedSessionType ?? this.selectedSessionType,
      slots: slots ?? this.slots,
      isSlotsLoading: isSlotsLoading ?? this.isSlotsLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdBooking: createdBooking ?? this.createdBooking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MyBookingsState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final bool isRefreshing;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const MyBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  MyBookingsState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    bool? isRefreshing,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
