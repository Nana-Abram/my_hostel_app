import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/service/notification_service.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification permission state provider
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.isNotificationPermissionGranted();
});

// FCM token provider
final fcmTokenProvider = Provider<String?>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.fcmToken;
});
