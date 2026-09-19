import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/network/api_client.dart';
import 'package:tarot_consultation_app/core/storage/secure_storage_service.dart';
import 'package:tarot_consultation_app/models/auth_response.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: apiClient, storage: storage);
});

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
      options: Options(extra: {'no-auth': true}),
    );

    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

    await _storage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await _storage.saveUser(authResponse.user);

    return authResponse;
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'password': password,
      },
      options: Options(extra: {'no-auth': true}),
    );

    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

    await _storage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await _storage.saveUser(authResponse.user);

    return authResponse;
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.currentUser);
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    await _storage.saveUser(user);
    return user;
  }

  Future<UserModel?> getCachedUser() async {
    return await _storage.getUser();
  }

  Future<bool> isAuthenticated() async {
    return await _storage.hasValidToken();
  }

  Future<void> logout() async {
    await _storage.clearAuthData();
  }
}
