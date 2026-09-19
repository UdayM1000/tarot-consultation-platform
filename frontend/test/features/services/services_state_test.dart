import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/services/domain/services_state.dart';
import 'package:tarot_consultation_app/models/category_model.dart';
import 'package:tarot_consultation_app/models/reading_service_model.dart';

void main() {
  group('ServicesCatalogState Tests', () {
    test('initial state should have empty lists and default flags', () {
      const state = ServicesCatalogState();

      expect(state.categories, isEmpty);
      expect(state.services, isEmpty);
      expect(state.selectedCategoryId, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isCategoriesLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.currentPage, 0);
      expect(state.hasMore, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('copyWith should update category selection and services correctly', () {
      const state = ServicesCatalogState();
      final updated = state.copyWith(
        selectedCategoryId: 1,
        categories: [
          const CategoryModel(id: 1, name: 'TAROT'),
          const CategoryModel(id: 2, name: 'RUNE'),
        ],
        services: [
          const ReadingServiceModel(
            id: 1,
            categoryId: 1,
            categoryName: 'TAROT',
            name: 'Yes / No Tarot',
            slug: 'yes-no-tarot',
            description: 'Short description',
            price: 50.0,
            durationMinutes: 15,
          ),
        ],
      );

      expect(updated.selectedCategoryId, 1);
      expect(updated.categories.length, 2);
      expect(updated.services.length, 1);
      expect(updated.services.first.name, 'Yes / No Tarot');
    });

    test('clearSelectedCategory should reset selectedCategoryId to null', () {
      final state = const ServicesCatalogState().copyWith(selectedCategoryId: 2);
      expect(state.selectedCategoryId, 2);

      final cleared = state.copyWith(clearSelectedCategory: true);
      expect(cleared.selectedCategoryId, isNull);
    });

    test('clearError should reset errorMessage to null', () {
      final state = const ServicesCatalogState().copyWith(errorMessage: 'Network timeout');
      expect(state.errorMessage, 'Network timeout');

      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });
}
