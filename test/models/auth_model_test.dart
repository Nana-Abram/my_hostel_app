import 'package:flutter_test/flutter_test.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';

void main() {
  group('UserModel', () {
    final baseMap = {
      'email': 'john@example.com',
      'fullName': 'John Doe',
      'phone': '+233201234567',
      'profileImage': null,
      'createdAt': '2024-01-15T10:00:00.000',
      'lastLogin': '2024-06-01T08:30:00.000',
      'role': 'student',
      'isEmailVerified': true,
      'managedHostels': null,
      'bio': 'A student',
      'location': 'Accra',
    };

    test('fromMap parses all fields correctly', () {
      final user = UserModel.fromMap(baseMap, 'uid-123');

      expect(user.id, 'uid-123');
      expect(user.email, 'john@example.com');
      expect(user.fullName, 'John Doe');
      expect(user.phone, '+233201234567');
      expect(user.role, UserRole.student);
      expect(user.isEmailVerified, true);
      expect(user.bio, 'A student');
      expect(user.location, 'Accra');
    });

    test('fromMap → toMap round-trip preserves all values', () {
      final user = UserModel.fromMap(baseMap, 'uid-123');
      final map = user.toMap();

      expect(map['email'], baseMap['email']);
      expect(map['fullName'], baseMap['fullName']);
      expect(map['phone'], baseMap['phone']);
      expect(map['role'], 'student');
      expect(map['isEmailVerified'], true);
    });

    test('fromMap defaults missing email/fullName to empty string', () {
      final user = UserModel.fromMap({
        'role': 'student',
        'createdAt': '2024-01-01T00:00:00.000',
      }, 'uid-456');

      expect(user.email, '');
      expect(user.fullName, '');
    });

    test('fromMap defaults missing createdAt to now without throwing', () {
      expect(
        () => UserModel.fromMap({'role': 'student'}, 'uid-789'),
        returnsNormally,
      );
    });

    test('fromMap handles null lastLogin', () {
      final user = UserModel.fromMap({...baseMap, 'lastLogin': null}, 'uid-1');
      expect(user.lastLogin, isNull);
    });

    test('fromMap parses managedHostels list', () {
      final user = UserModel.fromMap({
        ...baseMap,
        'managedHostels': ['hostel-1', 'hostel-2'],
      }, 'uid-1');
      expect(user.managedHostels, ['hostel-1', 'hostel-2']);
    });

    test('helper getters reflect role correctly', () {
      final student = UserModel.fromMap(baseMap, 'uid-1');
      expect(student.isStudent, true);
      expect(student.isAdmin, false);
      expect(student.isHostelOwner, false);

      final admin = UserModel.fromMap({...baseMap, 'role': 'admin'}, 'uid-2');
      expect(admin.isAdmin, true);
      expect(admin.isStudent, false);

      final owner = UserModel.fromMap({...baseMap, 'role': 'hostelOwner'}, 'uid-3');
      expect(owner.isHostelOwner, true);
    });

    test('copyWith updates only specified fields', () {
      final user = UserModel.fromMap(baseMap, 'uid-1');
      final updated = user.copyWith(fullName: 'Jane Doe', bio: 'Updated bio');

      expect(updated.fullName, 'Jane Doe');
      expect(updated.bio, 'Updated bio');
      expect(updated.email, user.email); // unchanged
      expect(updated.role, user.role);   // unchanged
      expect(updated.id, user.id);       // unchanged
    });
  });

  group('UserRole', () {
    test('fromMap falls back to student for unknown role string', () {
      final user = UserModel.fromMap({
        'email': 'x@x.com',
        'fullName': 'X',
        'role': 'superuser', // unknown
        'createdAt': '2024-01-01T00:00:00.000',
      }, 'uid-1');
      expect(user.role, UserRole.student);
    });

    test('fromMap falls back to student when role key is missing', () {
      final user = UserModel.fromMap({
        'email': 'x@x.com',
        'fullName': 'X',
        'createdAt': '2024-01-01T00:00:00.000',
      }, 'uid-1');
      expect(user.role, UserRole.student);
    });

    test('displayName returns readable labels', () {
      expect(UserRole.student.displayName, 'Student');
      expect(UserRole.admin.displayName, 'Admin');
      expect(UserRole.hostelOwner.displayName, 'Hostel Owner');
    });

    test('toMap serialises role as enum name', () {
      for (final role in UserRole.values) {
        final user = UserModel.fromMap({
          'email': 'a@a.com',
          'fullName': 'A',
          'role': role.name,
          'createdAt': '2024-01-01T00:00:00.000',
        }, 'uid');
        expect(user.toMap()['role'], role.name);
      }
    });
  });
}
