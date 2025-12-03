import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/service/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userStream;
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  
  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, next) {
      state = next;
    });
  }

  // ADD THIS METHOD: Update user data locally without fetching from Firebase
  void updateUser(UserModel updatedUser) {
    if (state is AsyncData<UserModel?>) {
      state = AsyncData(updatedUser);
    }
  }

  // ADD THIS METHOD: Update specific user fields
  void updateUserFields(Map<String, dynamic> updates) {
    if (state is AsyncData<UserModel?>) {
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          fullName: updates['fullName'] as String? ?? currentUser.fullName,
          email: updates['email'] as String? ?? currentUser.email,
          phone: updates['phone'] as String? ?? currentUser.phone,
          bio: updates['bio'] as String? ?? currentUser.bio,
          location: updates['location'] as String? ?? currentUser.location,
          profileImage: updates['profileImage'] as String? ?? currentUser.profileImage,
        );
        state = AsyncData(updatedUser);
      }
    }
  }

  // In your auth_provider.dart, update the refreshUser method
Future<void> refreshUser() async {
  try {
    print("🔄 [Auth] Starting refreshUser...");
    state = const AsyncValue.loading();
    final authService = ref.read(authServiceProvider);
    final currentUser = await authService.getCurrentUser();
    print("✅ [Auth] refreshUser completed. User: ${currentUser?.id}");
    state = AsyncData(currentUser);
  } catch (e, stack) {
    print("❌ [Auth] refreshUser failed: $e");
    state = AsyncValue.error(e, stack);
  }
}

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
  }
}

// Form state providers
final loginFormProvider = StateProvider<Map<String, String>>((ref) => {});
final signupFormProvider = StateProvider<Map<String, String>>((ref) => {});
final authLoadingProvider = StateProvider<bool>((ref) => false);