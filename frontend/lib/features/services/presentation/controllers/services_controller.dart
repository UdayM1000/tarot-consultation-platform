import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/features/services/data/services_repository.dart';
import 'package:tarot_consultation_app/features/services/domain/services_state.dart';
import 'package:tarot_consultation_app/models/category_model.dart';
import 'package:tarot_consultation_app/models/page_response.dart';
import 'package:tarot_consultation_app/models/reading_service_model.dart';

final servicesCatalogProvider =
    StateNotifierProvider<ServicesCatalogNotifier, ServicesCatalogState>((ref) {
  final repository = ref.watch(servicesRepositoryProvider);
  return ServicesCatalogNotifier(repository);
});

final serviceDetailProvider =
    FutureProvider.family<ReadingServiceModel, int>((ref, serviceId) async {
  final repository = ref.watch(servicesRepositoryProvider);
  return repository.getServiceById(serviceId);
});

class ServicesCatalogNotifier extends StateNotifier<ServicesCatalogState> {
  final ServicesRepository _repository;

  ServicesCatalogNotifier(this._repository) : super(const ServicesCatalogState()) {
    loadInitialData();
  }

  /// Initial load: fetch both categories and page 0 of services
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, isCategoriesLoading: true, clearError: true);

    try {
      final categoriesFuture = _repository.getCategories();
      final servicesFuture = _repository.getServices(
        categoryId: state.selectedCategoryId,
        page: 0,
      );

      final results = await Future.wait([categoriesFuture, servicesFuture]);

      final categories = results[0] as List<CategoryModel>;
      final servicesPage = results[1] as PageResponse<ReadingServiceModel>;

      state = state.copyWith(
        categories: categories,
        services: servicesPage.content,
        currentPage: servicesPage.number,
        hasMore: servicesPage.hasNext,
        isLoading: false,
        isCategoriesLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isCategoriesLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Select a category tab (null represents "All")
  Future<void> selectCategory(int? categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearSelectedCategory: categoryId == null,
      isLoading: true,
      clearError: true,
      currentPage: 0,
    );

    try {
      final pageResponse = await _repository.getServices(
        categoryId: categoryId,
        page: 0,
      );

      state = state.copyWith(
        services: pageResponse.content,
        currentPage: pageResponse.number,
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

  /// Pull to refresh current category services
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final categoriesFuture = _repository.getCategories();
      final servicesFuture = _repository.getServices(
        categoryId: state.selectedCategoryId,
        page: 0,
      );

      final results = await Future.wait([categoriesFuture, servicesFuture]);
      final categories = results[0] as List<CategoryModel>;
      final servicesPage = results[1] as PageResponse<ReadingServiceModel>;

      state = state.copyWith(
        categories: categories,
        services: servicesPage.content,
        currentPage: 0,
        hasMore: servicesPage.hasNext,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load next page when user scrolls near the bottom
  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    try {
      final pageResponse = await _repository.getServices(
        categoryId: state.selectedCategoryId,
        page: nextPage,
      );

      state = state.copyWith(
        services: [...state.services, ...pageResponse.content],
        currentPage: pageResponse.number,
        hasMore: pageResponse.hasNext,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
