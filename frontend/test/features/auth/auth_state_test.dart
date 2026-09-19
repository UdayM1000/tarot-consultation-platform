import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/features/auth/domain/auth_state.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

void main() {
  group('AuthState Tests', () {
    test('initial state should be unauthenticated with no user', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.user, isNull);
    });

    test('copyWith authenticated user should set isAuthenticated to true', () {
      const user = UserModel(
        id: 1,
        name: 'Seeker',
        email: 'seeker@test.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );

      final state = const AuthState().copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );

      expect(state.isAuthenticated, true);
      expect(state.user?.name, 'Seeker');
      expect(state.status, AuthStatus.authenticated);
    });

    test('copyWith clearUser should reset user to null', () {
      const user = UserModel(
        id: 1,
        name: 'Seeker',
        email: 'seeker@test.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );

      final state = const AuthState(status: AuthStatus.authenticated, user: user)
          .copyWith(status: AuthStatus.unauthenticated, clearUser: true);

      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });
  });
}
