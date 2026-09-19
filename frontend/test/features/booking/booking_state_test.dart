import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/booking/domain/booking_state.dart';
import 'package:tarot_consultation_app/models/booking_model.dart';
import 'package:tarot_consultation_app/models/time_slot_model.dart';

void main() {
  group('BookingCreationState Tests', () {
    test('initial state should default to tomorrow and VIDEO session', () {
      final state = BookingCreationState();

      expect(state.selectedSessionType, 'VIDEO');
      expect(state.selectedSlot, isNull);
      expect(state.slots, isEmpty);
      expect(state.isSlotsLoading, isFalse);
      expect(state.isSubmitting, isFalse);
      expect(state.createdBooking, isNull);
      expect(state.errorMessage, isNull);

      // Verify default date is tomorrow
      final now = DateTime.now();
      expect(state.selectedDate.isAfter(DateTime(now.year, now.month, now.day)), isTrue);
    });

    test('copyWith should update slot and session type correctly', () {
      final state = BookingCreationState();
      const slot = TimeSlotModel(
        startTime: '10:00',
        endTime: '10:15',
        available: true,
      );

      final updated = state.copyWith(
        selectedSlot: slot,
        selectedSessionType: 'AUDIO',
        isSubmitting: true,
      );

      expect(updated.selectedSlot, slot);
      expect(updated.selectedSessionType, 'AUDIO');
      expect(updated.isSubmitting, isTrue);
    });

    test('clearSlot should reset selectedSlot to null', () {
      const slot = TimeSlotModel(
        startTime: '10:00',
        endTime: '10:15',
        available: true,
      );

      final state = BookingCreationState().copyWith(selectedSlot: slot);
      expect(state.selectedSlot, slot);

      final cleared = state.copyWith(clearSlot: true);
      expect(cleared.selectedSlot, isNull);
    });
  });

  group('MyBookingsState Tests', () {
    test('initial state should have empty list', () {
      const state = MyBookingsState();

      expect(state.bookings, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.currentPage, 0);
      expect(state.hasMore, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('copyWith should populate bookings list', () {
      const state = MyBookingsState();
      final scheduled = DateTime(2026, 9, 25, 10, 0);
      final booking = BookingModel(
        id: 1,
        bookingReference: 'TR-2026-000001',
        customerId: 3,
        customerName: 'Seeker',
        customerEmail: 'seeker@test.com',
        serviceId: 1,
        serviceName: 'Yes / No Tarot',
        serviceSlug: 'yes-no-tarot',
        durationMinutes: 15,
        scheduledStart: scheduled,
        scheduledEnd: scheduled.add(const Duration(minutes: 15)),
        sessionType: 'VIDEO',
        priceAtBooking: 50.0,
        status: 'PENDING',
        disclaimerAccepted: true,
      );

      final updated = state.copyWith(
        bookings: [booking],
        isLoading: false,
      );

      expect(updated.bookings.length, 1);
      expect(updated.bookings.first.bookingReference, 'TR-2026-000001');
    });
  });
}
