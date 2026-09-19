import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_consultation_app/core/network/api_exception.dart';
import 'package:tarot_consultation_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tarot_consultation_app/features/booking/data/booking_repository.dart';
import 'package:tarot_consultation_app/features/profile/data/user_repository.dart';
import 'package:tarot_consultation_app/features/profile/domain/profile_state.dart';
import 'package:tarot_consultation_app/features/reading_outcomes/data/reading_repository.dart';
import 'package:tarot_consultation_app/models/change_password_request_model.dart';
import 'package:tarot_consultation_app/models/update_profile_request_model.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final readingRepository = ref.watch(readingRepositoryProvider);
  final authNotifier = ref.watch(authControllerProvider.notifier);

  return ProfileNotifier(
    userRepository: userRepository,
    bookingRepository: bookingRepository,
    readingRepository: readingRepository,
    authNotifier: authNotifier,
  );
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepository _userRepository;
  final BookingRepository _bookingRepository;
  final ReadingRepository _readingRepository;
  final AuthController _authNotifier;

  ProfileNotifier({
    required UserRepository userRepository,
    required BookingRepository bookingRepository,
    required ReadingRepository readingRepository,
    required AuthController authNotifier,
  })  : _userRepository = userRepository,
        _bookingRepository = bookingRepository,
        _readingRepository = readingRepository,
        _authNotifier = authNotifier,
        super(const ProfileState());

  /// Loads the customer profile and consultation statistics
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      final user = await _userRepository.getCurrentUser();
      
      int bookingsCount = 0;
      int readingsCount = 0;

      try {
        final bookingsPage = await _bookingRepository.getMyBookings();
        bookingsCount = bookingsPage.totalElements;
      } catch (_) {
        // Continue if bookings count fails
      }

      try {
        final readings = await _readingRepository.getCustomerReadings();
        readingsCount = readings.length;
      } catch (_) {
        // Continue if readings count fails
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        bookingCount: bookingsCount,
        readingCount: readingsCount,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load profile. Please check your connection.',
      );
    }
  }

  /// Updates customer name and phone
  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? profileImage,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      final request = UpdateProfileRequestModel(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

      final updatedUser = await _userRepository.updateProfile(request);

      _authNotifier.updateUser(updatedUser);

      state = state.copyWith(
        isSaving: false,
        user: updatedUser,
        successMessage: 'Profile updated successfully.',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  /// Changes customer password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isChangingPassword: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final message = await _userRepository.changePassword(request);

      state = state.copyWith(
        isChangingPassword: false,
        successMessage: message.isNotEmpty ? message : 'Password changed successfully.',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isChangingPassword: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isChangingPassword: false,
        errorMessage: 'Failed to change password. Please check your credentials.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
