import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/notification_model.dart';
import 'package:my_hostel_app/backend/service/notification_repository.dart';
import 'package:my_hostel_app/backend/service/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository());

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  return ref.watch(notificationServiceProvider).isNotificationPermissionGranted();
});

final fcmTokenProvider = Provider<String?>((ref) {
  return ref.watch(notificationServiceProvider).fcmToken;
});

/// Live stream of all notifications for a user (latest 50).
final notificationsProvider =
    StreamProvider.autoDispose.family<List<NotificationModel>, String>(
  (ref, userId) {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getNotificationsStream(userId);
  },
);

/// Live unread notification count — drives the bell badge on the dashboard.
final unreadNotificationsCountProvider =
    StreamProvider.autoDispose.family<int, String>(
  (ref, userId) {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getUnreadCount(userId);
  },
);

/// Watched by DashboardScreen to start/stop the Firestore real-time listener.
/// Automatically cancels when the dashboard leaves the tree.
final notificationListenerProvider =
    Provider.autoDispose.family<void, String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  service.startListeningForUser(userId);
  ref.onDispose(service.stopListening);
});
