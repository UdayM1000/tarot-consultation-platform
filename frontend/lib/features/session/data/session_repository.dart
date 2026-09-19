import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../models/create_session_request_model.dart';
import '../../../models/session_model.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SessionRepository(apiClient);
});

class SessionRepository {
  final ApiClient _apiClient;

  SessionRepository(this._apiClient);

  /// Fetch or initialize session room for confirmed booking
  Future<SessionModel> getOrCreateSession(int bookingId, {String? provider}) async {
    final request = CreateSessionRequestModel(bookingId: bookingId, provider: provider);
    final response = await _apiClient.post(
      ApiConstants.sessions,
      data: request.toJson(),
    );
    final data = response.data as Map<String, dynamic>;
    return SessionModel.fromJson(data);
  }

  /// Get current session status and join URL
  Future<SessionModel> getSession(int bookingId) async {
    final response = await _apiClient.get(
      ApiConstants.sessionByBooking(bookingId),
    );
    final data = response.data as Map<String, dynamic>;
    return SessionModel.fromJson(data);
  }

  /// Mark session as ACTIVE
  Future<SessionModel> startSession(int bookingId) async {
    final response = await _apiClient.put(
      ApiConstants.startSession(bookingId),
    );
    final data = response.data as Map<String, dynamic>;
    return SessionModel.fromJson(data);
  }

  /// Mark session as ENDED
  Future<SessionModel> endSession(int bookingId) async {
    final response = await _apiClient.put(
      ApiConstants.endSession(bookingId),
    );
    final data = response.data as Map<String, dynamic>;
    return SessionModel.fromJson(data);
  }
}
