import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/service/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Auth state ─────────────────────────────────────────────────────────────

  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirebaseUser(firebaseUser);
    });
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirebaseUser(firebaseUser);
  }

  // Role comes entirely from Firestore — never inferred from email.
  // To bootstrap the very first admin, set role='admin' directly in the
  // Firebase console on that user's /users/{uid} document.
  Future<UserModel> _getUserFromFirebaseUser(User firebaseUser) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data == null) throw Exception('User document data is empty.');
        return UserModel.fromMap(data, firebaseUser.uid);
      } else {
        // First-time social login — create the document
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          fullName: firebaseUser.displayName ?? 'User',
          profileImage: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
          role: UserRole.student,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      throw Exception('Error fetching user data: ${e.toString()}');
    }
  }

  // ── Sign up ────────────────────────────────────────────────────────────────

  /// [pin] is required when [role] is admin or hostelOwner.
  /// It is validated against the value stored in Firestore config/roleAccess
  /// before the account is created, so a wrong PIN never produces an orphan
  /// Firebase Auth record.
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole role = UserRole.student,
    String? pin,
  }) async {
    try {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        throw 'Please enter a valid email address';
      }

      // Validate role PIN against Firestore before creating the account
      if (role != UserRole.student) {
        await _validateRolePin(role, pin);
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user!;

      final userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        role: role,
        isEmailVerified: false,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toMap());
      await firebaseUser.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      // Re-throw user-facing string messages (e.g. from _validateRolePin)
      // unchanged; wrap anything else so the type isn't lost.
      if (e is String) rethrow;
      throw Exception(e.toString());
    }
  }

  /// Fetches the role PIN config from Firestore and compares it with [pin].
  /// Throws a user-friendly string on failure.
  Future<void> _validateRolePin(UserRole role, String? pin) async {
    if (pin == null || pin.isEmpty) {
      throw 'A security PIN is required for the ${role.displayName} role.';
    }
    try {
      final configDoc = await _firestore
          .collection('config')
          .doc('roleAccess')
          .get();

      if (!configDoc.exists || configDoc.data() == null) {
        throw 'Role access is not configured. Contact the administrator.';
      }

      final pinField =
          role == UserRole.admin ? 'adminPin' : 'ownerPin';
      final expectedPin = configDoc.data()![pinField] as String?;

      if (expectedPin == null || pin != expectedPin) {
        throw 'Invalid security PIN for the ${role.displayName} role.';
      }
    } on FirebaseException catch (e) {
      throw 'Could not verify PIN: ${e.message}';
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user!;

      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      final user = await _getUserFromFirebaseUser(firebaseUser);
      await NotificationService().saveFCMToken(firebaseUser.uid);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Google sign-in ─────────────────────────────────────────────────────────

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      final UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);
      final firebaseUser = userCredential.user!;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userDoc.exists) {
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });
      }

      return await _getUserFromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  // ── Password / account management ─────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw 'No user is currently signed in';
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw 'No user is currently signed in';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      } else {
        throw 'No user is currently signed in';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Role management ────────────────────────────────────────────────────────

  Future<void> promoteToAdmin(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': UserRole.admin.name});
    } catch (e) {
      throw 'Failed to promote user: ${e.toString()}';
    }
  }

  /// Demotes a user to student. Because role is read solely from Firestore
  /// on every login, this change takes effect the next time they sign in.
  Future<void> demoteToStudent(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': UserRole.student.name});
    } catch (e) {
      throw 'Failed to demote user: ${e.toString()}';
    }
  }

  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['role'] == UserRole.admin.name;
      }
      return false;
    } catch (e) {
      throw 'Failed to check admin status: ${e.toString()}';
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw 'Failed to fetch users: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data == null) return null;
        return UserModel.fromMap(data, userId);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user: ${e.toString()}';
    }
  }

  // ── Error handling ─────────────────────────────────────────────────────────

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That doesn\'t look like a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Try something longer or more complex.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'requires-recent-login':
        return 'Please sign out and sign back in before doing this.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
