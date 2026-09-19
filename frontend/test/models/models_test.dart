import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/api_error_response.dart';
import 'package:tarot_consultation_app/models/auth_response.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

void main() {
  group('UserModel JSON Serialization', () {
    test('should correctly parse UserResponse from Spring Boot backend', () {
      final json = {
        'id': 3,
        'name': 'Seeker Priya',
        'email': 'customer@tarotplatform.com',
        'phone': '+919999900003',
        'profileImage': null,
        'roles': ['CUSTOMER'],
        'isActive': true,
        'createdAt': '2026-09-19T23:04:51.223179',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 3);
      expect(user.name, 'Seeker Priya');
      expect(user.email, 'customer@tarotplatform.com');
      expect(user.phone, '+919999900003');
      expect(user.roles, contains('CUSTOMER'));
      expect(user.isActive, true);
      expect(user.createdAt, isNotNull);
    });

    test('should serialize UserModel back to JSON correctly', () {
      const user = UserModel(
        id: 1,
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Jane Doe');
      expect(json['email'], 'jane@example.com');
      expect(json['roles'], ['CUSTOMER']);
    });
  });

  group('AuthResponse Serialization', () {
    test('should parse backend AuthResponse with tokens and nested User', () {
      final json = {
        'accessToken': 'jwt.token.access',
        'refreshToken': 'jwt.token.refresh',
        'tokenType': 'Bearer',
        'expiresIn': 3600000,
        'user': {
          'id': 10,
          'name': 'Astrid',
          'email': 'astrid@tarot.com',
          'roles': ['READER'],
          'isActive': true,
        },
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.accessToken, 'jwt.token.access');
      expect(authResponse.refreshToken, 'jwt.token.refresh');
      expect(authResponse.tokenType, 'Bearer');
      expect(authResponse.expiresIn, 3600000);
      expect(authResponse.user.name, 'Astrid');
      expect(authResponse.user.roles, contains('READER'));
    });
  });

  group('ApiErrorResponse Serialization', () {
    test('should parse backend ErrorResponse with validation errors', () {
      final json = {
        'timestamp': '2026-09-19T10:00:00',
        'status': 400,
        'error': 'Bad Request',
        'message': 'Validation failed for fields',
        'path': '/api/v1/auth/register',
        'validationErrors': {
          'email': 'Email must be valid',
          'password': 'Password too short',
        },
      };

      final error = ApiErrorResponse.fromJson(json);

      expect(error.status, 400);
      expect(error.error, 'Bad Request');
      expect(error.message, 'Validation failed for fields');
      expect(error.validationErrors?['email'], 'Email must be valid');
      expect(error.validationErrors?['password'], 'Password too short');
    });
  });
}
