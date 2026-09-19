import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/booking_model.dart';
import 'package:tarot_consultation_app/models/create_booking_request_model.dart';
import 'package:tarot_consultation_app/models/time_slot_model.dart';

void main() {
  group('TimeSlotModel JSON Serialization', () {
    test('should parse backend TimeSlotResponse correctly', () {
      final json = {
        'startTime': '10:00:00',
        'endTime': '10:15:00',
        'available': true,
        'readerId': 2,
        'readerName': 'Master Reader Astrid',
      };

      final slot = TimeSlotModel.fromJson(json);

      expect(slot.startTime, '10:00');
      expect(slot.endTime, '10:15');
      expect(slot.available, isTrue);
      expect(slot.readerId, 2);
      expect(slot.readerName, 'Master Reader Astrid');
      expect(slot.formattedStartTime, '10:00 AM');
      expect(slot.formattedEndTime, '10:15 AM');
      expect(slot.formattedTimeRange, '10:00 AM - 10:15 AM');
    });

    test('should handle PM times and 12-hour format properly', () {
      final json = {
        'startTime': '14:30',
        'endTime': '15:15',
        'available': false,
        'readerId': null,
        'readerName': null,
      };

      final slot = TimeSlotModel.fromJson(json);

      expect(slot.formattedStartTime, '02:30 PM');
      expect(slot.formattedEndTime, '03:15 PM');
      expect(slot.available, isFalse);
    });
  });

  group('CreateBookingRequestModel JSON Serialization', () {
    test('should serialize correctly according to backend validation constraints', () {
      final scheduledStart = DateTime(2026, 9, 25, 10, 0, 0);
      final request = CreateBookingRequestModel(
        serviceId: 1,
        scheduledStart: scheduledStart,
        sessionType: 'VIDEO',
        question: 'What career direction should I pursue?',
        additionalInformation: 'Transitioning from finance to tech.',
        disclaimerAccepted: true,
      );

      final json = request.toJson();

      expect(json['serviceId'], 1);
      expect(json['scheduledStart'], scheduledStart.toIso8601String());
      expect(json['sessionType'], 'VIDEO');
      expect(json['question'], 'What career direction should I pursue?');
      expect(json['additionalInformation'], 'Transitioning from finance to tech.');
      expect(json['disclaimerAccepted'], isTrue);
    });

    test('should omit empty optional fields', () {
      final scheduledStart = DateTime(2026, 9, 25, 11, 0, 0);
      final request = CreateBookingRequestModel(
        serviceId: 2,
        scheduledStart: scheduledStart,
        sessionType: 'CHAT',
        disclaimerAccepted: true,
      );

      final json = request.toJson();

      expect(json['serviceId'], 2);
      expect(json['sessionType'], 'CHAT');
      expect(json.containsKey('question'), isFalse);
      expect(json.containsKey('additionalInformation'), isFalse);
      expect(json['disclaimerAccepted'], isTrue);
    });
  });

  group('BookingModel JSON Serialization', () {
    test('should parse backend BookingResponse payload correctly', () {
      final json = {
        'id': 101,
        'bookingReference': 'TR-2026-000101',
        'customerId': 3,
        'customerName': 'Seeker Priya',
        'customerEmail': 'customer@tarotplatform.com',
        'serviceId': 1,
        'serviceName': 'Yes / No Tarot',
        'serviceSlug': 'yes-no-tarot',
        'durationMinutes': 15,
        'scheduledStart': '2026-09-25T10:00:00',
        'scheduledEnd': '2026-09-25T10:15:00',
        'sessionType': 'VIDEO',
        'question': 'Will I relocate this year?',
        'additionalInformation': 'Applied for jobs abroad.',
        'priceAtBooking': 50.00,
        'status': 'PENDING',
        'disclaimerAccepted': true,
        'createdAt': '2026-09-19T18:00:00',
        'updatedAt': '2026-09-19T18:00:00',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, 101);
      expect(booking.bookingReference, 'TR-2026-000101');
      expect(booking.customerName, 'Seeker Priya');
      expect(booking.serviceName, 'Yes / No Tarot');
      expect(booking.durationMinutes, 15);
      expect(booking.sessionType, 'VIDEO');
      expect(booking.priceAtBooking, 50.00);
      expect(booking.formattedPrice, '₹50.00');
      expect(booking.status, 'PENDING');
      expect(booking.isPending, isTrue);
      expect(booking.isConfirmed, isFalse);
      expect(booking.disclaimerAccepted, isTrue);
      expect(booking.formattedScheduledTime, '10:00 AM');
    });
  });
}
