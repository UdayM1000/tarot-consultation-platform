import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/models/create_review_request_model.dart';
import 'package:tarot_consultation_app/models/review_model.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewRepository(apiClient);
});

class ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepository(this._apiClient);

  /// Submit review for a completed consultation
  Future<ReviewModel> createReview(CreateReviewRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.reviews,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  /// Get public approved reviews
  Future<List<ReviewModel>> getApprovedReviews({int page = 0, int size = 15}) async {
    final response = await _apiClient.get(
      ApiConstants.reviews,
      queryParameters: {'page': page, 'size': size},
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('content') && map['content'] is List) {
        final list = map['content'] as List;
        return list
            .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (response.data is List) {
      final list = response.data as List;
      return list
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
