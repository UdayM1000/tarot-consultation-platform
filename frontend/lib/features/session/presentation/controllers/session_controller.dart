import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/session/data/session_repository.dart';
import 'package:tarot_consultation_app/features/session/domain/session_state.dart';

final sessionRoomProvider = StateNotifierProvider.family
    .autoDispose<SessionRoomNotifier, SessionRoomState, int>((ref, bookingId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionRoomNotifier(repository, bookingId);
});

class SessionRoomNotifier extends StateNotifier<SessionRoomState> {
  final SessionRepository _repository;
  final int _bookingId;

  SessionRoomNotifier(this._repository, this._bookingId)
      : super(SessionRoomState(bookingId: _bookingId)) {
    loadSession();
  }

  /// Initialize or fetch session for booking
  Future<void> loadSession() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final session = await _repository.getOrCreateSession(_bookingId);
      state = state.copyWith(
        session: () => session,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to connect to consultation session: $e',
      );
    }
  }

  /// Start consultation session
  Future<bool> startSession() async {
    state = state.copyWith(isActionLoading: true, errorMessage: () => null);
    try {
      final updated = await _repository.startSession(_bookingId);
      state = state.copyWith(
        session: () => updated,
        isActionLoading: false,
        actionSuccessMessage: () => 'Consultation session is now live!',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: () => e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: () => 'Could not start session: $e',
      );
      return false;
    }
  }

  /// End consultation session
  Future<bool> endSession() async {
    state = state.copyWith(isActionLoading: true, errorMessage: () => null);
    try {
      final updated = await _repository.endSession(_bookingId);
      state = state.copyWith(
        session: () => updated,
        isActionLoading: false,
        actionSuccessMessage: () => 'Consultation session concluded.',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: () => e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: () => 'Could not end session: $e',
      );
      return false;
    }
  }
}
