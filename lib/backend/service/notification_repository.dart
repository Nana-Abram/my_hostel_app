import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/notification_model.dart';

class NotificationRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  /// Persist a notification for a user. Called by NotificationService.
  Future<void> saveNotification(
    String userId, {
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _col(userId).add({
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live stream of the 50 most recent notifications for a user.
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _col(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Live stream of unread notification count.
  Stream<int> getUnreadCount(String userId) {
    return _col(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  Future<void> markAsRead(String userId, String notifId) async {
    await _col(userId).doc(notifId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final unread =
        await _col(userId).where('isRead', isEqualTo: false).get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> delete(String userId, String notifId) async {
    await _col(userId).doc(notifId).delete();
  }

  Future<void> clearAll(String userId) async {
    final batch = _firestore.batch();
    final all = await _col(userId).get();
    for (final doc in all.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
