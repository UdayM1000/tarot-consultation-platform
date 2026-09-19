import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/domain/reading_outcomes_state.dart';
import 'package:tarot_consultation_app/models/reading_result_model.dart';
import 'package:tarot_consultation_app/models/tarot_card_reading_model.dart';

void main() {
  group('MyReadingsState Tests', () {
    test('initial state has empty readings list and default flags', () {
      const state = MyReadingsState();

      expect(state.readings, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates readings list and error message', () {
      const state = MyReadingsState();

      final reading = ReadingResultModel(
        id: 1,
        bookingId: 101,
        bookingReference: 'TR-2026-000101',
        customerId: 2,
        customerName: 'Seeker',
        customerEmail: 'seeker@test.com',
        serviceName: 'Tarot Spread',
        summary: 'Deep spiritual path',
        advice: 'Take time to meditate',
        tarotCards: const [
          TarotCardReadingModel(
            id: 1,
            cardName: 'The Star',
            position: 'Hope',
            interpretation: 'Inspiration',
          ),
        ],
        createdAt: DateTime.now(),
      );

      final updated = state.copyWith(
        readings: [reading],
        isLoading: false,
      );

      expect(updated.readings.length, 1);
      expect(updated.readings.first.serviceName, 'Tarot Spread');
      expect(updated.readings.first.hasTarotCards, isTrue);
      expect(updated.readings.first.hasRuneReadings, isFalse);
    });

    test('copyWith resets errorMessage when null function provided', () {
      const state = MyReadingsState(errorMessage: 'Network timeout');
      expect(state.errorMessage, 'Network timeout');

      final cleared = state.copyWith(errorMessage: () => null);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('ReadingDetailState Tests', () {
    test('initial state has readingId and null reading', () {
      const state = ReadingDetailState(readingId: 5);

      expect(state.readingId, 5);
      expect(state.reading, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates reading dossier correctly', () {
      const state = ReadingDetailState(readingId: 5);

      final reading = ReadingResultModel(
        id: 5,
        bookingId: 105,
        bookingReference: 'TR-2026-000105',
        customerId: 2,
        customerName: 'Seeker',
        customerEmail: 'seeker@test.com',
        serviceName: 'Rune Cast',
        summary: 'Cosmic changes',
        advice: 'Follow inner strength',
        createdAt: DateTime.now(),
      );

      final updated = state.copyWith(
        reading: () => reading,
        isLoading: false,
      );

      expect(updated.reading, isNotNull);
      expect(updated.reading?.id, 5);
      expect(updated.reading?.serviceName, 'Rune Cast');
    });
  });
}
