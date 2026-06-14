import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/service/notification_repository.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background handler — must be a top-level function
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  debugPrint('[FCM] Data: ${message.data}');
  debugPrint('[FCM] Notification: ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification channel IDs
// ─────────────────────────────────────────────────────────────────────────────
class _Channels {
  static const String bookingId = 'booking_channel';
  static const String bookingName = 'Booking Notifications';
  static const String bookingDesc = 'Alerts for booking status changes';

  static const String paymentId = 'payment_channel';
  static const String paymentName = 'Payment Notifications';
  static const String paymentDesc = 'Alerts for payment confirmations';

  static const String generalId = 'general_channel';
  static const String generalName = 'General Notifications';
  static const String generalDesc = 'General app notifications';
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream that the router listens to for navigation on tap
  final StreamController<Map<String, dynamic>> _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  final NotificationRepository _repository = NotificationRepository();
  StreamSubscription<QuerySnapshot>? _firestoreListenerSub;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapController.stream;

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.info(
          '[FCM] Permission status: ${settings.authorizationStatus}');

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!granted) {
        AppLogger.warn('[FCM] Permission not granted — notifications disabled');
        return;
      }

      await _initializeLocalNotifications();
      await _createNotificationChannels();

      // Fetch token
      _fcmToken = await _fcm.getToken();
      AppLogger.info('[FCM] Token: $_fcmToken');

      // Refresh token listener
      _fcm.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        AppLogger.info('[FCM] Token refreshed');
        await _saveTokenForCurrentUser();
      });

      _setupMessageHandlers();
    } catch (e, stack) {
      AppLogger.error('[FCM] Initialization error', e, stack);
    }
  }

  // ── Local notifications setup ─────────────────────────────────────────────

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
      // Handle taps while app was terminated
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundLocalNotificationTapped,
    );
  }

  /// Create the Android notification channels so the system can categorise
  /// notifications by importance before they are shown.
  Future<void> _createNotificationChannels() async {
    const bookingChannel = AndroidNotificationChannel(
      _Channels.bookingId,
      _Channels.bookingName,
      description: _Channels.bookingDesc,
      importance: Importance.high,
    );

    const paymentChannel = AndroidNotificationChannel(
      _Channels.paymentId,
      _Channels.paymentName,
      description: _Channels.paymentDesc,
      importance: Importance.high,
    );

    const generalChannel = AndroidNotificationChannel(
      _Channels.generalId,
      _Channels.generalName,
      description: _Channels.generalDesc,
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(bookingChannel);
    await androidPlugin?.createNotificationChannel(paymentChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  // ── Message handlers ──────────────────────────────────────────────────────

  void _setupMessageHandlers() {
    // 1. App is in the foreground — show local notification banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('[FCM] Foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 2. App is in the background and user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('[FCM] Notification opened from background');
      _handleNotificationTap(message.data);
    });

    // 3. App was terminated and user taps the notification
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info('[FCM] App launched from notification');
        // Slight delay so the router is ready before navigating
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(message.data);
        });
      }
    });
  }

  // ── Show local notification ───────────────────────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] as String? ?? 'general';
    final channelId = _channelIdForType(type);
    final channelName = _channelNameForType(type);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: message.notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
          color: const Color(0xFF2196F3),
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  String _channelIdForType(String type) {
    switch (type) {
      case 'booking':
        return _Channels.bookingId;
      case 'payment':
        return _Channels.paymentId;
      default:
        return _Channels.generalId;
    }
  }

  String _channelNameForType(String type) {
    switch (type) {
      case 'booking':
        return _Channels.bookingName;
      case 'payment':
        return _Channels.paymentName;
      default:
        return _Channels.generalName;
    }
  }

  // ── Tap handlers ──────────────────────────────────────────────────────────

  void _onLocalNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTap(data);
      } catch (e) {
        AppLogger.error('[FCM] Failed to parse notification payload', e);
      }
    }
  }

  /// This must be a top-level or static function (Flutter restriction).
  @pragma('vm:entry-point')
  static void _onBackgroundLocalNotificationTapped(
      NotificationResponse response) {
    // The singleton instance handles it via the stream once the app is alive.
    if (response.payload != null) {
      try {
        final data =
            json.decode(response.payload!) as Map<String, dynamic>;
        NotificationService()._handleNotificationTap(data);
      } catch (_) {}
    }
  }

  /// Pushes the notification data onto the stream that app_routes.dart listens
  /// to, which then calls router.go() with the correct path.
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];
    AppLogger.info('[FCM] Tap → type=$type, id=$id');

    if (!_notificationTapController.isClosed) {
      _notificationTapController.add(data);
    }
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<void> _saveTokenForCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await saveFCMToken(currentUser.uid);
    }
  }

  Future<void> saveFCMToken(String userId) async {
    if (_fcmToken == null) return;
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('[FCM] Token saved for user: $userId');
    } catch (e) {
      AppLogger.error('[FCM] Error saving token', e);
    }
  }

  Future<void> removeFCMToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      AppLogger.info('[FCM] Token removed for user: $userId');
    } catch (e) {
      AppLogger.error('[FCM] Error removing token', e);
    }
  }

  // ── Firestore real-time listener ─────────────────────────────────────────

  /// Start watching the current user's notification subcollection.
  /// Any document added AFTER this call triggers a local notification banner.
  void startListeningForUser(String userId) {
    _firestoreListenerSub?.cancel();

    // Only surface notifications that arrive after the session starts.
    final sessionStart = Timestamp.now();

    _firestoreListenerSub = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('createdAt', isGreaterThan: sessionStart)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final d = change.doc.data();
          if (d == null) continue;
          showNotification(
            id: change.doc.id.hashCode,
            title: d['title'] as String? ?? '',
            body: d['body'] as String? ?? '',
            type: d['type'] as String? ?? 'general',
            data: Map<String, dynamic>.from(d['data'] ?? {}),
          );
        }
      }
    }, onError: (e) {
      AppLogger.error('[Notif] Firestore listener error', e);
    });

    AppLogger.info('[Notif] Listening for notifications for $userId');
  }

  void stopListening() {
    _firestoreListenerSub?.cancel();
    _firestoreListenerSub = null;
    AppLogger.info('[Notif] Stopped notification listener');
  }

  // ── Send notification ─────────────────────────────────────────────────────

  /// Persists a notification to the target user's Firestore subcollection.
  /// The target user's device listener picks it up and shows a local banner.
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _repository.saveNotification(
        userId,
        title: title,
        body: body,
        type: data?['type'] as String? ?? 'general',
        data: data,
      );
      AppLogger.info('[Notif] Saved notification for $userId: $title');
    } catch (e) {
      AppLogger.error('[Notif] Error saving notification', e);
    }
  }

  // ── Topic subscriptions ───────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      AppLogger.info('[FCM] Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('[FCM] Subscribe error', e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      AppLogger.info('[FCM] Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('[FCM] Unsubscribe error', e);
    }
  }

  // ── Manual local notification ─────────────────────────────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelIdForType(type),
          _channelNameForType(type),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2196F3),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? json.encode(data) : null,
    );
  }

  // ── Permission helpers ────────────────────────────────────────────────────

  Future<bool> isNotificationPermissionGranted() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<bool> requestNotificationPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  void dispose() {
    _firestoreListenerSub?.cancel();
    _notificationTapController.close();
  }
}
