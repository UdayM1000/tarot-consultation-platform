import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/models/change_password_request_model.dart';
import 'package:tarot_consultation_app/models/update_profile_request_model.dart';
import 'package:tarot_consultation_app/models/user_model.dart';

void main() {
  group('Profile Models Serialization & Helpers', () {
    test('UpdateProfileRequestModel serialization without optional phone', () {
      const model = UpdateProfileRequestModel(
        name: 'Elena Rostova',
      );

      final json = model.toJson();
      expect(json['name'], equals('Elena Rostova'));
      expect(json.containsKey('phone'), isFalse);
      expect(json.containsKey('profileImage'), isFalse);
    });

    test('UpdateProfileRequestModel serialization with phone and profileImage', () {
      const model = UpdateProfileRequestModel(
        name: 'Elena Rostova',
        phone: '+1 555 0192',
        profileImage: 'https://images.unsplash.com/photo-mystic.jpg',
      );

      final json = model.toJson();
      expect(json['name'], equals('Elena Rostova'));
      expect(json['phone'], equals('+1 555 0192'));
      expect(json['profileImage'], equals('https://images.unsplash.com/photo-mystic.jpg'));

      final parsed = UpdateProfileRequestModel.fromJson(json);
      expect(parsed.name, equals('Elena Rostova'));
      expect(parsed.phone, equals('+1 555 0192'));
      expect(parsed.profileImage, equals('https://images.unsplash.com/photo-mystic.jpg'));
    });

    test('ChangePasswordRequestModel serialization', () {
      const model = ChangePasswordRequestModel(
        currentPassword: 'OldPassword123!',
        newPassword: 'NewSacredPassword456#',
      );

      final json = model.toJson();
      expect(json['currentPassword'], equals('OldPassword123!'));
      expect(json['newPassword'], equals('NewSacredPassword456#'));

      final parsed = ChangePasswordRequestModel.fromJson(json);
      expect(parsed.currentPassword, equals('OldPassword123!'));
      expect(parsed.newPassword, equals('NewSacredPassword456#'));
    });

    test('UserModel copyWith correctly modifies specified attributes', () {
      final user = UserModel(
        id: 10,
        name: 'Original Seeker',
        email: 'original@tarot.com',
        roles: const ['CUSTOMER'],
        isActive: true,
        createdAt: DateTime(2025, 3, 15),
      );

      final updated = user.copyWith(
        name: 'Ascended Seeker',
        phone: '+91 9876543210',
      );

      expect(updated.id, equals(10));
      expect(updated.name, equals('Ascended Seeker'));
      expect(updated.email, equals('original@tarot.com'));
      expect(updated.phone, equals('+91 9876543210'));
      expect(updated.roles, equals(['CUSTOMER']));
    });

    test('UserModel roleDisplay returns human-friendly badges', () {
      const seeker = UserModel(
        id: 1,
        name: 'Seeker One',
        email: 's1@tarot.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );
      expect(seeker.roleDisplay, equals('Seeker'));

      const reader = UserModel(
        id: 2,
        name: 'Master Reader',
        email: 'reader@tarot.com',
        roles: ['READER', 'CUSTOMER'],
        isActive: true,
      );
      expect(reader.roleDisplay, equals('Tarot & Rune Master'));

      const admin = UserModel(
        id: 3,
        name: 'High Priest Admin',
        email: 'admin@tarot.com',
        roles: ['ADMIN', 'READER'],
        isActive: true,
      );
      expect(admin.roleDisplay, equals('Admin'));
    });

    test('UserModel initials helper computes initials accurately', () {
      const singleName = UserModel(
        id: 1,
        name: 'Aurelia',
        email: 'a@tarot.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );
      expect(singleName.initials, equals('A'));

      const twoNames = UserModel(
        id: 2,
        name: 'Aurelia Moon',
        email: 'am@tarot.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );
      expect(twoNames.initials, equals('AM'));

      const emptyName = UserModel(
        id: 3,
        name: '  ',
        email: 'empty@tarot.com',
        roles: ['CUSTOMER'],
        isActive: true,
      );
      expect(emptyName.initials, equals('S'));
    });

    test('UserModel formattedMemberSince outputs Month and Year', () {
      final user = UserModel(
        id: 1,
        name: 'Aurelia',
        email: 'a@tarot.com',
        roles: const ['CUSTOMER'],
        isActive: true,
        createdAt: DateTime(2025, 9, 21),
      );
      expect(user.formattedMemberSince, equals('Sep 2025'));

      const userNullDate = UserModel(
        id: 2,
        name: 'Aurelia',
        email: 'a@tarot.com',
        roles: ['CUSTOMER'],
        isActive: true,
        createdAt: null,
      );
      expect(userNullDate.formattedMemberSince, equals('Sacred Initiate'));
    });
  });
}
