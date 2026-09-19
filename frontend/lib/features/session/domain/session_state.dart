import '../../../models/session_model.dart';

class SessionRoomState {
  final int bookingId;
  final SessionModel? session;
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const SessionRoomState({
    required this.bookingId,
    this.session,
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  SessionRoomState copyWith({
    int? bookingId,
    SessionModel? Function()? session,
    bool? isLoading,
    bool? isActionLoading,
    String? Function()? errorMessage,
    String? Function()? actionSuccessMessage,
  }) {
    return SessionRoomState(
      bookingId: bookingId ?? this.bookingId,
      session: session != null ? session() : this.session,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      actionSuccessMessage: actionSuccessMessage != null
          ? actionSuccessMessage()
          : this.actionSuccessMessage,
    );
  }
}
