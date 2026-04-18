import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Firebase Cloud Messaging (FCM) service for handling push notifications.
///
/// Features:
/// • Automatic token registration on first launch
/// • Background message handler (runs in isolation)
/// • Foreground message handler
/// • Token refresh handling
/// • Graceful fallback to local notifications if FCM unavailable
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  // Callbacks for different message scenarios
  Function(RemoteMessage)? _onMessageCallback;
  Function(RemoteMessage)? _onMessageOpenedAppCallback;

  // ── Initialisation ────────────────────────────────────────────────────

  /// Initialize FCM service. Must be called once during app startup.
  /// 
  /// Sets up:
  /// • Message handlers
  /// • Token registration
  /// • Notification permissions
  Future<void> initialize({
    Function(RemoteMessage)? onMessage,
    Function(RemoteMessage)? onMessageOpenedApp,
  }) async {
    if (_initialized) return;

    debugPrint('[FCMService] Initializing Firebase Cloud Messaging...');

    // Store callbacks
    _onMessageCallback = onMessage;
    _onMessageOpenedAppCallback = onMessageOpenedApp;

    // Request notification permissions (required on iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      debugPrint('[FCMService] Notification permissions: ${settings.authorizationStatus}');
    }

    // Get and register FCM token
    await _registerToken();

    // Listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      _registerToken();
    });

    // Set up message handlers
    _setupMessageHandlers();

    _initialized = true;
    debugPrint('[FCMService] Initialized successfully');
  }

  // ── Public API ────────────────────────────────────────────────────────

  /// Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('[FCMService] Error getting token: $e');
      return null;
    }
  }

  /// Subscribe to a topic for group messaging
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('[FCMService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FCMService] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('[FCMService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[FCMService] Error unsubscribing from topic: $e');
    }
  }

  /// Send a local notification fallback for testing or offline scenarios
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await NotificationService.instance.show(
      id: 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
    );
  }

  // ── Private Helpers ──────────────────────────────────────────────────

  /// Register or refresh the FCM token
  Future<void> _registerToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('[FCMService] FCM Token: ${token.substring(0, 20)}...');
        // TODO: Send token to backend for user tracking
        // await ApiService.instance.registerFCMToken(token);
      }
    } catch (e) {
      debugPrint('[FCMService] Error registering token: $e');
    }
  }

  /// Set up handlers for different message scenarios
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCMService] Foreground message: ${message.notification?.title}');

      // Show notification in foreground
      if (message.notification != null) {
        _handleForegroundMessage(message);
      }

      // Call custom callback if provided
      _onMessageCallback?.call(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCMService] Message opened app: ${message.notification?.title}');

      // Handle deep linking or navigation
      _onMessageOpenedAppCallback?.call(message);
    });

    // Handle background messages (this needs to be a top-level function)
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    debugPrint('[FCMService] Message handlers setup complete');
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      await NotificationService.instance.show(
        id: 'fcm_${message.messageId}',
        title: notification.title ?? 'NagarWatch',
        body: notification.body ?? '',
      );
    }

    // Parse and handle specific notification types
    final notificationType = data['type'] ?? 'default';
    
    switch (notificationType) {
      case 'issue_update':
        await _handleIssueUpdateNotification(data);
        break;
      case 'project_update':
        await _handleProjectUpdateNotification(data);
        break;
      case 'authority_sync':
        await _handleAuthoritySyncNotification(data);
        break;
      default:
        debugPrint('[FCMService] Unknown notification type: $notificationType');
    }
  }

  /// Handle issue update notifications
  Future<void> _handleIssueUpdateNotification(Map<String, dynamic> data) async {
    final issueTitle = data['issue_title'] ?? 'Issue';
    final status = data['status'] ?? 'updated';
    debugPrint('[FCMService] Issue update: $issueTitle → $status');
    // Additional logic can be added here
  }

  /// Handle project update notifications
  Future<void> _handleProjectUpdateNotification(Map<String, dynamic> data) async {
    final projectName = data['project_name'] ?? 'Project';
    final update = data['update'] ?? 'updated';
    debugPrint('[FCMService] Project update: $projectName → $update');
    // Additional logic can be added here
  }

  /// Handle authority sync notifications
  Future<void> _handleAuthoritySyncNotification(Map<String, dynamic> data) async {
    final authorityName = data['authority_name'] ?? 'Authority';
    debugPrint('[FCMService] Authority sync: $authorityName');
    // Additional logic can be added here
  }
}

/// Top-level function to handle background messages
/// Must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  debugPrint('[FCMService] Background message: ${message.notification?.title}');

  // Handle the background message
  if (message.notification != null) {
    await NotificationService.instance.show(
      id: 'fcm_bg_${message.messageId}',
      title: message.notification?.title ?? 'NagarWatch',
      body: message.notification?.body ?? '',
    );
  }
}
