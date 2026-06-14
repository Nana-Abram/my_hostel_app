import 'package:flutter_test/flutter_test.dart';

// The validators in login.dart / signup.dart are private widget methods.
// These tests mirror their logic directly so the underlying rules are covered.
// If the regex or length rules change in the widget, update these tests too.

final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your email';
  if (!_emailRegex.hasMatch(value)) return 'Please enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter a password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

void main() {
  group('Email validator', () {
    test('accepts standard valid emails', () {
      final valid = [
        'user@example.com',
        'john.doe+tag@mail.co.uk',
        'USER@DOMAIN.ORG',
        'a@b.io',
        'first.last@sub.domain.com',
      ];
      for (final email in valid) {
        expect(validateEmail(email), isNull, reason: '$email should be valid');
      }
    });

    test('rejects malformed emails', () {
      final invalid = [
        'not-an-email',
        '@nodomain.com',
        'missing@',
        'missing@domain',
        'space @example.com',
        '',
      ];
      for (final email in invalid) {
        expect(validateEmail(email), isNotNull,
            reason: '$email should be invalid');
      }
    });

    test('returns error for null', () {
      expect(validateEmail(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(validateEmail(''), 'Please enter your email');
    });
  });

  group('Password validator', () {
    test('accepts passwords of 6 or more characters', () {
      expect(validatePassword('abc123'), isNull);
      expect(validatePassword('longerPassword!'), isNull);
      expect(validatePassword('123456'), isNull);
    });

    test('rejects passwords shorter than 6 characters', () {
      expect(validatePassword('12345'), isNotNull);
      expect(validatePassword('a'), isNotNull);
      expect(validatePassword(''), 'Please enter a password');
    });

    test('returns error for null', () {
      expect(validatePassword(null), isNotNull);
    });

    test('returns correct error message for too-short password', () {
      expect(validatePassword('hi'), 'Password must be at least 6 characters');
    });
  });
}
