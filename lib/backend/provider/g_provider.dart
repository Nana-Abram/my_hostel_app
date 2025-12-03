// Add to your auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';

final guaranteedUserProvider = FutureProvider<UserModel?>((ref) async {
  print("🔐 [GuaranteedUser] Starting check...");
  
  // First try to get from current state
  final authState = ref.watch(authProvider);
  final currentUser = authState.value;
  
  if (currentUser != null) {
    print("🔐 [GuaranteedUser] Found in state: ${currentUser.id}");
    return currentUser;
  }
  
  // If not in state, force refresh
  print("🔐 [GuaranteedUser] Not in state, forcing refresh...");
  try {
    final authService = ref.read(authServiceProvider);
    final refreshedUser = await authService.getCurrentUser();
    print("🔐 [GuaranteedUser] Refreshed: ${refreshedUser?.id}");
    return refreshedUser;
  } catch (e) {
    print("❌ [GuaranteedUser] Failed: $e");
    return null;
  }
});