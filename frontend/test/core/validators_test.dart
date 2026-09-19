import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_consultation_app/core/utils/validators.dart';

void main() {
  group('Validators Utility Tests', () {
    test('validateEmail should reject null, empty, and invalid formats', () {
      expect(Validators.validateEmail(null), 'Email is required');
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('   '), 'Email is required');
      expect(Validators.validateEmail('not-an-email'), 'Enter a valid email address');
      expect(Validators.validateEmail('missing@domain'), 'Enter a valid email address');
      expect(Validators.validateEmail('valid@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@sub.domain.co'), isNull);
    });

    test('validatePassword should require at least 6 characters', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('StrongPassword@123'), isNull);
    });

    test('validateName should require at least 2 characters', () {
      expect(Validators.validateName(null), 'Full name is required');
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateName('a'), 'Name must be at least 2 characters');
      expect(Validators.validateName('Jane Doe'), isNull);
    });

    test('validateConfirmPassword should enforce match', () {
      expect(Validators.validateConfirmPassword(null, 'secret'), 'Please confirm your password');
      expect(Validators.validateConfirmPassword('different', 'secret'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('secret', 'secret'), isNull);
    });
  });
}
