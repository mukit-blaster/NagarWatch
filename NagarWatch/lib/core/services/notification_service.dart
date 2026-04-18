import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  final Map<String, DateTime> _cooldowns = {};
  static const Duration _cooldown = Duration(minutes: 30);

  /// Initialize notification service with both local and FCM support
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: false,
    );
    
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );

    // Request FCM permissions
    await _requestFCMPermissions();

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully');
  }

  /// Request Firebase Cloud Messaging permissions
  Future<void> _requestFCMPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        '[NotificationService] FCM permission status: ${settings.authorizationStatus}',
      );
    } catch (e) {
      debugPrint('[NotificationService] Error requesting FCM permissions: $e');
    }
  }

  /// Get FCM token for server-side push notifications
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('[NotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup FCM message handlers
  Future<void> setupFCMHandlers({
    Function(RemoteMessage)? onMessage,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    try {
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '[NotificationService] FCM foreground message: ${message.notification?.title}',
        );
        onMessage?.call(message);
      });

      // Handle messages when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
          '[NotificationService] FCM message opened app: ${message.notification?.title}',
        );
        onMessageOpenedApp?.call(message);
      });
    } catch (e) {
      debugPrint('[NotificationService] Error setting up FCM handlers: $e');
    }
  }

  /// Subscribe to a topic for group messaging
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint(
        '[NotificationService] Error subscribing to topic: $e',
      );
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint(
        '[NotificationService] Error unsubscribing from topic: $e',
      );
    }
  }

  /// Show local notification
  Future<void> show({
    required String id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    
    final last = _cooldowns[id];
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return;
    }

    _cooldowns[id] = DateTime.now();
    
    await _plugin.show(
      id.hashCode.abs() % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nagarwatch_ch',
          'NagarWatch',
          channelDescription: 'NagarWatch notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    
    debugPrint('[NotificationService] Notification shown: $title');
  }

  /// Notify about issue status change
  Future<void> notifyIssueStatusChanged(String issueTitle, String newStatus) =>
      show(
        id: 'issue_$issueTitle',
        title: '🔔 Issue Status Updated',
        body: '"$issueTitle" is now $newStatus',
      );

  /// Notify about nearby geofence entry
  Future<void> notifyGeofenceEntered(
    String projectName,
    String budget,
    String deadline,
  ) =>
      show(
        id: 'geo_$projectName',
        title: '📍 Nearby Project',
        body: '$projectName | Budget: $budget | Deadline: $deadline',
      );

  /// Notify about real-time issue update
  Future<void> notifyIssueUpdate(
    String issueId,
    String issueTitle,
    String updateMessage,
  ) =>
      show(
        id: 'update_$issueId',
        title: '🔄 Issue Updated',
        body: '$issueTitle: $updateMessage',
      );

  /// Notify about nearby issue from geofencing
  Future<void> notifyNearbyIssue(
    String issueId,
    String issueTitle,
    String areaName,
    String distance,
  ) =>
      show(
        id: 'nearby_$issueId',
        title: '📍 Issue Nearby',
        body: '$issueTitle in $areaName (${distance}km away)',
      );
}
