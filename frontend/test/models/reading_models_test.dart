import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/reading_result_model.dart';
import 'package:tarot_consultation_app/models/rune_reading_model.dart';
import 'package:tarot_consultation_app/models/tarot_card_reading_model.dart';

void main() {
  group('Reading Models Serialization & Helpers', () {
    final sampleJson = {
      'id': 301,
      'bookingId': 101,
      'bookingReference': 'TR-2026-000101',
      'customerId': 5,
      'customerName': 'Seeker Alice',
      'customerEmail': 'alice@example.com',
      'serviceName': '3-Card Past Present Future Tarot',
      'summary': 'A profound awakening is underway. The past anchors your clarity.',
      'advice': 'Trust your inner voice and do not fear quiet stillness.',
      'outcome': 'Spiritual equilibrium and creative abundance by next moon cycle.',
      'additionalNotes': 'Reader recommends meditating with amethyst or clear quartz.',
      'tarotCards': [
        {
          'id': 1,
          'cardName': 'The High Priestess',
          'position': 'Past',
          'interpretation': 'Intuitive wisdom rooted deep within your foundation.',
        },
        {
          'id': 2,
          'cardName': 'The Fool',
          'position': 'Present',
          'interpretation': 'A leap of faith into new spiritual chapters.',
        },
      ],
      'runeReadings': [
        {
          'id': 10,
          'runeName': 'Fehu',
          'position': 'Outcome Guidance',
          'interpretation': 'Circulation of wealth, creative energy, and spiritual abundance.',
        },
      ],
      'createdAt': '2026-09-19T18:00:00',
      'updatedAt': '2026-09-19T18:30:00',
    };

    test('should parse ReadingResultModel with nested cards and runes', () {
      final reading = ReadingResultModel.fromJson(sampleJson);

      expect(reading.id, 301);
      expect(reading.bookingId, 101);
      expect(reading.bookingReference, 'TR-2026-000101');
      expect(reading.serviceName, '3-Card Past Present Future Tarot');
      expect(reading.summary, contains('profound awakening'));
      expect(reading.advice, contains('Trust your inner voice'));
      expect(reading.outcome, contains('Spiritual equilibrium'));
      expect(reading.additionalNotes, contains('amethyst'));

      expect(reading.hasTarotCards, isTrue);
      expect(reading.tarotCards.length, 2);
      expect(reading.tarotCards[0].cardName, 'The High Priestess');
      expect(reading.tarotCards[0].position, 'Past');
      expect(reading.tarotCards[1].cardName, 'The Fool');

      expect(reading.hasRuneReadings, isTrue);
      expect(reading.runeReadings.length, 1);
      expect(reading.runeReadings[0].runeName, 'Fehu');
      expect(reading.runeReadings[0].glyph, 'ᚠ');
      expect(reading.cardCount, 3);
    });

    test('should serialize ReadingResultModel back to JSON', () {
      final reading = ReadingResultModel.fromJson(sampleJson);
      final json = reading.toJson();

      expect(json['id'], 301);
      expect(json['bookingId'], 101);
      expect((json['tarotCards'] as List).length, 2);
      expect((json['runeReadings'] as List).length, 1);
    });

    test('RuneReadingModel glyph mapping resolves authentic Norse runes', () {
      const fehu = RuneReadingModel(id: 1, runeName: 'Fehu', position: 'A', interpretation: '');
      expect(fehu.glyph, 'ᚠ');

      const uruz = RuneReadingModel(id: 2, runeName: 'Uruz', position: 'B', interpretation: '');
      expect(uruz.glyph, 'ᚢ');

      const ansuz = RuneReadingModel(id: 3, runeName: 'Ansuz', position: 'C', interpretation: '');
      expect(ansuz.glyph, 'ᚨ');

      const thurisaz = RuneReadingModel(id: 4, runeName: 'Thurisaz', position: 'D', interpretation: '');
      expect(thurisaz.glyph, 'ᚦ');

      const unknown = RuneReadingModel(id: 5, runeName: 'CustomRune', position: 'E', interpretation: '');
      expect(unknown.glyph, 'ᛟ');
    });

    test('TarotCardReadingModel serialization and deserialization', () {
      const card = TarotCardReadingModel(
        id: 7,
        cardName: 'The Empress',
        position: 'Heart of Matter',
        interpretation: 'Fertility, divine connection, and nurturing love.',
      );
      final json = card.toJson();

      expect(json['id'], 7);
      expect(json['cardName'], 'The Empress');

      final deserialized = TarotCardReadingModel.fromJson(json);
      expect(deserialized.id, 7);
      expect(deserialized.cardName, 'The Empress');
      expect(deserialized.position, 'Heart of Matter');
    });
  });
}
