import 'package:tarot_consultation_app/models/user_model.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final bool isChangingPassword;
  final UserModel? user;
  final int bookingCount;
  final int readingCount;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.isChangingPassword = false,
    this.user,
    this.bookingCount = 0,
    this.readingCount = 0,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isChangingPassword,
    UserModel? user,
    int? bookingCount,
    int? readingCount,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      user: user ?? this.user,
      bookingCount: bookingCount ?? this.bookingCount,
      readingCount: readingCount ?? this.readingCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
