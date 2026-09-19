import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/models/category_model.dart';
import 'package:tarot_consultation_app/models/page_response.dart';
import 'package:tarot_consultation_app/models/reading_service_model.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ServicesRepository(apiClient);
});

class ServicesRepository {
  final ApiClient _apiClient;

  ServicesRepository(this._apiClient);

  /// Fetch all active service categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch paginated reading services, with optional category filter
  Future<PageResponse<ReadingServiceModel>> getServices({
    int? categoryId,
    int page = 0,
    int size = 20,
    String sortBy = 'price',
    String sortDir = 'asc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': '$sortBy,$sortDir',
    };
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }

    final response = await _apiClient.get(
      ApiConstants.services,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return PageResponse<ReadingServiceModel>.fromJson(
      data,
      (itemJson) => ReadingServiceModel.fromJson(itemJson),
    );
  }

  /// Fetch single reading service details by numeric ID
  Future<ReadingServiceModel> getServiceById(int id) async {
    final response = await _apiClient.get('${ApiConstants.services}/$id');
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return ReadingServiceModel.fromJson(data);
  }

  /// Fetch single reading service details by slug
  Future<ReadingServiceModel> getServiceBySlug(String slug) async {
    final response = await _apiClient.get('${ApiConstants.services}/slug/$slug');
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return ReadingServiceModel.fromJson(data);
  }
}
