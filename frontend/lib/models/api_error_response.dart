class ApiErrorResponse {
  final int status;
  final String error;
  final String message;
  final Map<String, String>? validationErrors;

  const ApiErrorResponse({
    required this.status,
    required this.error,
    required this.message,
    this.validationErrors,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    Map<String, String>? valErrors;
    if (json['validationErrors'] is Map) {
      valErrors = (json['validationErrors'] as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return ApiErrorResponse(
      status: json['status'] is int ? json['status'] as int : 500,
      error: json['error'] as String? ?? 'Error',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      validationErrors: valErrors,
    );
  }
}
