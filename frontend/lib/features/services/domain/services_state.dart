import '../../../models/category_model.dart';
import '../../../models/reading_service_model.dart';

class ServicesCatalogState {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final List<ReadingServiceModel> services;
  final bool isLoading;
  final bool isCategoriesLoading;
  final bool isRefreshing;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const ServicesCatalogState({
    this.categories = const [],
    this.selectedCategoryId,
    this.services = const [],
    this.isLoading = false,
    this.isCategoriesLoading = false,
    this.isRefreshing = false,
    this.currentPage = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  ServicesCatalogState copyWith({
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
    List<ReadingServiceModel>? services,
    bool? isLoading,
    bool? isCategoriesLoading,
    bool? isRefreshing,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ServicesCatalogState(
      categories: categories ?? this.categories,
      selectedCategoryId:
          clearSelectedCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
