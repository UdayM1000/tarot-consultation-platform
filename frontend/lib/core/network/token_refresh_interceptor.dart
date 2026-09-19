import 'package:dio/dio.dart';
import 'package:tarot_consultation_app/core/constants/api_constants.dart';
import 'package:tarot_consultation_app/core/storage/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final void Function()? onSessionExpired;

  bool _isRefreshing = false;

  TokenRefreshInterceptor(this._dio, this._storage, {this.onSessionExpired});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;

    // Do not attempt refresh on auth endpoints themselves
    final isAuthEndpoint = path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.register) ||
        path.contains(ApiConstants.refresh);

    if (statusCode == 401 && !isAuthEndpoint) {
      if (_isRefreshing) {
        return handler.reject(err);
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _handleLogout();
          return handler.reject(err);
        }

        // Call backend refresh endpoint using an independent Dio client without interceptors
        final refreshDio = Dio(BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ));

        final response = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final newAccessToken = response.data['accessToken'] as String?;
          final newRefreshToken = response.data['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            await _storage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        }

        await _handleLogout();
        _isRefreshing = false;
        return handler.reject(err);
      } catch (e) {
        _isRefreshing = false;
        await _handleLogout();
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }

  Future<void> _handleLogout() async {
    await _storage.clearAuthData();
    onSessionExpired?.call();
  }
}
