import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin emails - store this in Firestore for better management
  final List<String> _adminEmails = [
    'admin@hostelhub.com',
    'superadmin@hostelhub.com'
  ];

  // Stream to track auth state changes
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirebaseUser(firebaseUser);
    });
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirebaseUser(firebaseUser);
  }

  // Helper method to get UserModel from Firebase User
  Future<UserModel> _getUserFromFirebaseUser(User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
      } else {
        // Create new user document if it doesn't exist (for social logins)
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          fullName: firebaseUser.displayName ?? 'User',
          profileImage: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
          role: _adminEmails.contains(firebaseUser.email) ? UserRole.admin : UserRole.student,
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      throw 'Error fetching user data: ${e.toString()}';
    }
  }

  // Email & Password Sign Up with Role Selection
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole role = UserRole.student,
  }) async {
    try {
      // Validate email format
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        throw 'Please enter a valid email address';
      }

      // Check if email already exists
      // final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      // if (signInMethods.isNotEmpty) {
      //   throw 'An account already exists with this email address';
      // }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Determine user role (admin emails get admin role, otherwise use selected role)
      final UserRole userRole = _adminEmails.contains(email) 
          ? UserRole.admin 
          : role;

      // Create user document in Firestore
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        role: userRole,
        isEmailVerified: false,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());

      // Send email verification
      await firebaseUser.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Email & Password Login
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

      // Update last login
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      return await _getUserFromFirebaseUser(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Google Sign In - Using Firebase Auth Provider (works on web)
  Future<UserModel> signInWithGoogle() async {
    try {
      // Create Google Auth Provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Add scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      // Sign in with popup (for web)
      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      
      final firebaseUser = userCredential.user!;

      // Check if user document exists, if not it will be created by _getUserFromFirebaseUser
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        // Update last login for existing user
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

  // Facebook Sign In (Optional - requires setup)
  Future<UserModel> signInWithFacebook() async {
    // Note: You'll need to set up Facebook login separately
    // This is a placeholder for future implementation
    throw 'Facebook login is not yet implemented';
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Resend Email Verification
  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw 'No user is currently signed in';
    }
  }

  // Update user profile
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

  // Change Password
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

  // Delete User Account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      } else {
        throw 'No user is currently signed in';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Promote user to admin (for super admin use)
  Future<void> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': UserRole.admin.name,
      });
    } catch (e) {
      throw 'Failed to promote user: ${e.toString()}';
    }
  }

  // Demote admin to student
  Future<void> demoteToStudent(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': UserRole.student.name,
      });
    } catch (e) {
      throw 'Failed to demote user: ${e.toString()}';
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['role'] == UserRole.admin.name;
      }
      return false;
    } catch (e) {
      throw 'Failed to check admin status: ${e.toString()}';
    }
  }

  // Get all users (admin only)
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

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!, userId);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user: ${e.toString()}';
    }
  }

  // Update admin emails list
  void updateAdminEmails(List<String> newAdminEmails) {
    // In production, you might want to store this in Firestore
    _adminEmails.clear();
    _adminEmails.addAll(newAdminEmails);
  }

  // Get current admin emails
  List<String> get adminEmails => List.unmodifiable(_adminEmails);

  // Error handling
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}