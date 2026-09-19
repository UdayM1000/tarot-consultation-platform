import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/models/change_password_request_model.dart';
import 'package:tarot_consultation_app/models/update_profile_request_model.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
});

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  /// Fetch authenticated user's current profile
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.currentUser);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update user profile details (name, phone, profileImage)
  Future<UserModel> updateProfile(UpdateProfileRequestModel request) async {
    final response = await _apiClient.put(
      ApiConstants.updateProfile,
      data: request.toJson(),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Change user password
  Future<String> changePassword(ChangePasswordRequestModel request) async {
    final response = await _apiClient.put(
      ApiConstants.changePassword,
      data: request.toJson(),
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      return map['message'] as String? ?? 'Password changed successfully';
    }
    return 'Password changed successfully';
  }
}
