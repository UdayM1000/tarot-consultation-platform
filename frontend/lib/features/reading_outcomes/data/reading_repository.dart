import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/models/reading_result_model.dart';

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReadingRepository(apiClient);
});

class ReadingRepository {
  final ApiClient _apiClient;

  ReadingRepository(this._apiClient);

  /// Fetch paginated readings history for authenticated customer
  Future<List<ReadingResultModel>> getCustomerReadings({int page = 0, int size = 10}) async {
    final response = await _apiClient.get(
      ApiConstants.readings,
      queryParameters: {'page': page, 'size': size},
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('content') && map['content'] is List) {
        final list = map['content'] as List;
        return list
            .map((item) => ReadingResultModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (response.data is List) {
      final list = response.data as List;
      return list
          .map((item) => ReadingResultModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get specific reading outcome by ID
  Future<ReadingResultModel> getReadingById(int id) async {
    final response = await _apiClient.get('${ApiConstants.readings}/$id');
    final data = response.data as Map<String, dynamic>;
    return ReadingResultModel.fromJson(data);
  }
}
