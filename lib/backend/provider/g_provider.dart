// Add to your auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

final guaranteedUserProvider = FutureProvider<UserModel?>((ref) async {
  AppLogger.info('Guaranteed user check started');
  
  // First try to get from current state
  final authState = ref.watch(authProvider);
  final currentUser = authState.value;
  
  if (currentUser != null) {
    AppLogger.info('Guaranteed user found in state: ${currentUser.id}');
    return currentUser;
  }
  
  // If not in state, force refresh
  AppLogger.info('Guaranteed user not in state, forcing refresh');
  try {
    final authService = ref.read(authServiceProvider);
    final refreshedUser = await authService.getCurrentUser();
    AppLogger.info('Guaranteed user refreshed: ${refreshedUser?.id}');
    return refreshedUser;
  } catch (e) {
    AppLogger.error('Guaranteed user refresh failed', e);
    return null;
  }
});