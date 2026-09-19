import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/category_model.dart';
import 'package:tarot_consultation_app/models/page_response.dart';
import 'package:tarot_consultation_app/models/reading_service_model.dart';

void main() {
  group('CategoryModel JSON Serialization', () {
    test('should parse backend CategoryResponse correctly', () {
      final json = {
        'id': 1,
        'name': 'TAROT',
        'description': 'Tarot card readings providing intuitive wisdom',
        'active': true,
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, 1);
      expect(category.name, 'TAROT');
      expect(category.description, 'Tarot card readings providing intuitive wisdom');
      expect(category.active, isTrue);

      final backToJson = category.toJson();
      expect(backToJson['id'], 1);
      expect(backToJson['name'], 'TAROT');
    });

    test('should handle null description gracefully', () {
      final json = {
        'id': 2,
        'name': 'RUNE',
        'description': null,
        'active': true,
      };

      final category = CategoryModel.fromJson(json);
      expect(category.id, 2);
      expect(category.name, 'RUNE');
      expect(category.description, isNull);
    });
  });

  group('ReadingServiceModel JSON Serialization', () {
    test('should parse backend ReadingServiceResponse correctly', () {
      final json = {
        'id': 1,
        'categoryId': 1,
        'categoryName': 'TAROT',
        'name': 'Yes / No Tarot',
        'slug': 'yes-no-tarot',
        'description': '1 direct question, 3 tarot cards, clear answer, no follow-ups.',
        'price': 50.00,
        'durationMinutes': 15,
        'active': true,
        'questionRequired': true,
        'cardCountDescription': '3 tarot cards',
        'createdAt': '2026-09-19T10:00:00',
        'updatedAt': '2026-09-19T10:00:00',
      };

      final service = ReadingServiceModel.fromJson(json);

      expect(service.id, 1);
      expect(service.categoryId, 1);
      expect(service.categoryName, 'TAROT');
      expect(service.name, 'Yes / No Tarot');
      expect(service.slug, 'yes-no-tarot');
      expect(service.price, 50.00);
      expect(service.formattedPrice, '₹50.00');
      expect(service.durationMinutes, 15);
      expect(service.formattedDuration, '15 mins');
      expect(service.questionRequired, isTrue);
      expect(service.cardCountDescription, '3 tarot cards');
      expect(service.active, isTrue);
    });

    test('should format combo service with rune stones and higher price', () {
      final json = {
        'id': 10,
        'categoryId': 3,
        'categoryName': 'COMBO',
        'name': 'Tarot + Rune Confirmation',
        'slug': 'tarot-rune-confirmation',
        'description': 'Tarot reading followed by Rune Stone confirmation.',
        'price': 150.0,
        'durationMinutes': 60,
        'active': true,
        'questionRequired': true,
        'cardCountDescription': 'Full Tarot spread with Rune stone confirmation',
      };

      final service = ReadingServiceModel.fromJson(json);

      expect(service.id, 10);
      expect(service.formattedPrice, '₹150.00');
      expect(service.formattedDuration, '60 mins');
      expect(service.cardCountDescription, 'Full Tarot spread with Rune stone confirmation');
    });
  });

  group('PageResponse Generic Serialization', () {
    test('should parse Spring Data Page json into typed items and pagination flags', () {
      final pageJson = {
        'content': [
          {
            'id': 1,
            'categoryId': 1,
            'categoryName': 'TAROT',
            'name': 'Yes / No Tarot',
            'slug': 'yes-no-tarot',
            'description': 'Short description',
            'price': 50.0,
            'durationMinutes': 15,
            'active': true,
            'questionRequired': true,
            'cardCountDescription': '3 cards',
          },
          {
            'id': 2,
            'categoryId': 1,
            'categoryName': 'TAROT',
            'name': 'General Guidance',
            'slug': 'general-guidance',
            'description': 'Short description',
            'price': 50.0,
            'durationMinutes': 20,
            'active': true,
            'questionRequired': false,
            'cardCountDescription': '3 cards',
          },
        ],
        'totalPages': 1,
        'totalElements': 2,
        'size': 20,
        'number': 0,
        'last': true,
        'first': true,
        'empty': false,
      };

      final page = PageResponse<ReadingServiceModel>.fromJson(
        pageJson,
        (item) => ReadingServiceModel.fromJson(item),
      );

      expect(page.content.length, 2);
      expect(page.content[0].name, 'Yes / No Tarot');
      expect(page.content[1].name, 'General Guidance');
      expect(page.totalPages, 1);
      expect(page.totalElements, 2);
      expect(page.isFirst, isTrue);
      expect(page.isLast, isTrue);
      expect(page.hasNext, isFalse);
      expect(page.isEmpty, isFalse);
    });
  });
}
