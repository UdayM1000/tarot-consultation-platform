import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/core/theme/theme_provider.dart';
import 'package:tarot_consultation_app/features/profile/domain/profile_state.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

void main() {
  group('ProfileState Tests', () {
    test('initial state defaults are correct', () {
      const state = ProfileState();

      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.isChangingPassword, isFalse);
      expect(state.user, isNull);
      expect(state.bookingCount, equals(0));
      expect(state.readingCount, equals(0));
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });

    test('copyWith updates state attributes properly', () {
      const state = ProfileState();
      const user = UserModel(
        id: 42,
        name: 'Celeste',
        email: 'celeste@sanctuary.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );

      final updated = state.copyWith(
        isLoading: false,
        isSaving: false,
        user: user,
        bookingCount: 5,
        readingCount: 3,
        successMessage: 'Profile saved.',
      );

      expect(updated.user?.name, equals('Celeste'));
      expect(updated.bookingCount, equals(5));
      expect(updated.readingCount, equals(3));
      expect(updated.successMessage, equals('Profile saved.'));
      expect(updated.errorMessage, isNull);
    });

    test('clearError and clearSuccess flags clear respective messages', () {
      const state = ProfileState(
        errorMessage: 'An error occurred',
        successMessage: 'Success',
      );

      final cleared = state.copyWith(
        clearError: true,
        clearSuccess: true,
      );

      expect(cleared.errorMessage, isNull);
      expect(cleared.successMessage, isNull);
    });
  });

  group('ThemeNotifier Tests', () {
    test('initial theme is dark mode', () {
      final notifier = ThemeNotifier();
      expect(notifier.state, equals(ThemeMode.dark));
      expect(notifier.isDarkMode, isTrue);
    });

    test('toggleTheme alternates between dark and light modes', () {
      final notifier = ThemeNotifier();
      expect(notifier.state, equals(ThemeMode.dark));

      notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.light));
      expect(notifier.isDarkMode, isFalse);

      notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.dark));
      expect(notifier.isDarkMode, isTrue);
    });

    test('setTheme sets explicit ThemeMode', () {
      final notifier = ThemeNotifier();
      notifier.setTheme(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));

      notifier.setTheme(ThemeMode.system);
      expect(notifier.state, equals(ThemeMode.system));
    });
  });
}
