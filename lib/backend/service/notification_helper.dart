import 'package:my_hostel_app/backend/service/notification_service.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';

/// Helper class to send notifications for various app events
class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Send booking confirmation notification to student
  static Future<void> sendBookingConfirmationToStudent({
    required String userId,
    required String hostelName,
    required String bookingId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '🎉 Booking Confirmed!',
      body: 'Your booking at $hostelName has been confirmed.',
      data: {
        'type': 'booking',
        'id': bookingId,
        'action': 'confirmed',
      },
    );
  }

  /// Send new booking notification to hostel owner
  static Future<void> sendNewBookingToOwner({
    required String ownerId,
    required String studentName,
    required String hostelName,
    required String bookingId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: ownerId,
      title: '📋 New Booking Request',
      body: '$studentName has requested to book at $hostelName.',
      data: {
        'type': 'booking',
        'id': bookingId,
        'action': 'new',
      },
    );
  }

  /// Send booking rejection notification to student
  static Future<void> sendBookingRejectionToStudent({
    required String userId,
    required String hostelName,
    required String bookingId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '❌ Booking Not Confirmed',
      body: 'Your booking request at $hostelName was not confirmed.',
      data: {
        'type': 'booking',
        'id': bookingId,
        'action': 'rejected',
      },
    );
  }

  /// Send check-in reminder to student
  static Future<void> sendCheckInReminder({
    required String userId,
    required String hostelName,
    required String bookingId,
    required DateTime checkInDate,
  }) async {
    final daysLeft = checkInDate.difference(DateTime.now()).inDays;
    
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '📅 Check-in Reminder',
      body: 'Your check-in at $hostelName is in $daysLeft day${daysLeft > 1 ? 's' : ''}!',
      data: {
        'type': 'booking',
        'id': bookingId,
        'action': 'reminder',
      },
    );
  }

  /// Send payment confirmation notification
  static Future<void> sendPaymentConfirmation({
    required String userId,
    required double amount,
    required String bookingId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '💳 Payment Received',
      body: 'Your payment of GHS ${amount.toStringAsFixed(2)} has been confirmed.',
      data: {
        'type': 'payment',
        'id': bookingId,
        'action': 'confirmed',
      },
    );
  }

  /// Send payment reminder
  static Future<void> sendPaymentReminder({
    required String userId,
    required double amount,
    required String bookingId,
    required DateTime dueDate,
  }) async {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '⏰ Payment Due Soon',
      body: 'Payment of GHS ${amount.toStringAsFixed(2)} is due in $daysLeft day${daysLeft > 1 ? 's' : ''}.',
      data: {
        'type': 'payment',
        'id': bookingId,
        'action': 'reminder',
      },
    );
  }

  /// Send cancellation notification to owner
  static Future<void> sendCancellationToOwner({
    required String ownerId,
    required String studentName,
    required String hostelName,
    required String bookingId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: ownerId,
      title: '🚫 Booking Cancelled',
      body: '$studentName has cancelled their booking at $hostelName.',
      data: {
        'type': 'booking',
        'id': bookingId,
        'action': 'cancelled',
      },
    );
  }

  /// Send message notification
  static Future<void> sendMessageNotification({
    required String recipientId,
    required String senderName,
    required String messagePreview,
    required String chatId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: recipientId,
      title: '💬 New Message from $senderName',
      body: messagePreview,
      data: {
        'type': 'message',
        'id': chatId,
        'action': 'new',
      },
    );
  }

  /// Send review notification to owner
  static Future<void> sendReviewNotification({
    required String ownerId,
    required String studentName,
    required String hostelName,
    required int rating,
    required String reviewId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: ownerId,
      title: '⭐ New Review',
      body: '$studentName left a $rating-star review for $hostelName.',
      data: {
        'type': 'review',
        'id': reviewId,
        'action': 'new',
      },
    );
  }

  /// Send account verification notification
  static Future<void> sendAccountVerified({
    required String userId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '✅ Account Verified',
      body: 'Your account has been successfully verified!',
      data: {
        'type': 'account',
        'action': 'verified',
      },
    );
  }

  /// Send promotional notification
  static Future<void> sendPromotionalNotification({
    required String userId,
    required String title,
    required String message,
    String? promoId,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: title,
      body: message,
      data: {
        'type': 'promo',
        'id': promoId ?? '',
        'action': 'view',
      },
    );
  }

  /// Broadcast notification to all users in a topic
  static Future<void> broadcastNotification({
    required String topic,
    required String title,
    required String message,
  }) async {
    // This would typically be done server-side via Cloud Functions
    // For now, we just log it
    print('Broadcasting to topic $topic: $title - $message');
  }
}
