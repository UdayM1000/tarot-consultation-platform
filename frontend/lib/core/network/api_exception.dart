import 'package:dio/dio.dart';
import '../../models/api_error_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType;
  final Map<String, String>? validationErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
    this.validationErrors,
  });

  factory ApiException.fromDioError(DioException error) =>
      ApiException.fromDioException(error);

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect. Please check your internet connection.',
          statusCode: null,
          errorType: 'NETWORK_ERROR',
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data != null && response.data is Map<String, dynamic>) {
          try {
            final errorResponse = ApiErrorResponse.fromJson(response.data as Map<String, dynamic>);
            return ApiException(
              message: errorResponse.message,
              statusCode: errorResponse.status,
              errorType: errorResponse.error,
              validationErrors: errorResponse.validationErrors,
            );
          } catch (_) {
            // Fallback
          }
        }

        final code = response?.statusCode;
        if (code == 401) {
          return ApiException(
            message: 'Your session has expired. Please login again.',
            statusCode: 401,
            errorType: 'UNAUTHORIZED',
          );
        } else if (code == 403) {
          return ApiException(
            message: 'You do not have permission to perform this action.',
            statusCode: 403,
            errorType: 'FORBIDDEN',
          );
        } else if (code == 404) {
          return ApiException(
            message: 'The requested resource was not found.',
            statusCode: 404,
            errorType: 'NOT_FOUND',
          );
        } else if (code == 409) {
          return ApiException(
            message: 'This time slot or resource is in conflict.',
            statusCode: 409,
            errorType: 'CONFLICT',
          );
        }

        return ApiException(
          message: 'Server error (${code ?? 500}). Please try again later.',
          statusCode: code ?? 500,
          errorType: 'SERVER_ERROR',
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          errorType: 'CANCELLED',
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          errorType: 'UNKNOWN',
        );
    }
  }

  @override
  String toString() => message;
}
