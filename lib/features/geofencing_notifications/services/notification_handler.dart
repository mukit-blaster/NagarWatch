// lib/features/geofencing_notifications/services/notification_handler.dart

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/geofence_model.dart';

/// In-memory notification item that can be rendered inside the dashboard.
class DashboardNotification {
  DashboardNotification({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  final int id;
  final String areaId;
  final String areaName;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
}

/// Lightweight wrapper around [FlutterLocalNotificationsPlugin] for
/// NagarWatch geofence-related notifications.
///
/// Features:
/// • Singleton so the plugin is initialised only once across the app.
/// • Duplicate-spam prevention — won't re-notify for the same area id.
/// • Time-based cooldown — won't re-notify for a previously notified area
///   until [cooldownDuration] has elapsed (FR-3.4).
/// • Dashboard feed support — keeps a lightweight in-memory history for the
///   authority dashboard so detections are visible inside the app as well.
class NotificationHandler extends ChangeNotifier {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Tracks the last notified area id to prevent immediate duplicates.
  String? _lastNotifiedAreaId;

  /// Tracks timestamps of the last notification per area id for cooldown.
  final Map<String, DateTime> _notificationTimestamps = {};

  /// In-app dashboard notification feed.
  final List<DashboardNotification> _notifications = [];

  /// Minimum interval before re-notifying the same area.
  static const Duration cooldownDuration = Duration(minutes: 30);

  /// Maximum number of in-app notifications to retain.
  static const int _maxStoredNotifications = 30;

  UnmodifiableListView<DashboardNotification> get notifications =>
      UnmodifiableListView(_notifications);

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  int get totalCount => _notifications.length;

  bool get hasNotifications => _notifications.isNotEmpty;

  // ── Initialisation ────────────────────────────────────────────────────

  /// Call once from the provider's [initialize] or the app startup flow.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[NotificationHandler] Initialised successfully.');
  }

  // ── Public API ────────────────────────────────────────────────────────

  /// Shows a notification when an area is detected for the first time.
  Future<void> showAreaDetected(GeofenceArea area) async {
    if (!_shouldNotify(area.id)) return;

    const title = '📍 Area Detected';
    final body =
        'You are near ${area.name}, ${area.upazila}, ${area.district}.';

    _pushToDashboard(
      areaId: area.id,
      areaName: area.name,
      title: title,
      body: body,
    );

    await _show(
      id: _notificationId(area.id),
      title: title,
      body: body,
    );

    _recordNotification(area.id);
  }

  /// Shows a notification when the detected area changes from one to another.
  Future<void> showAreaChanged(GeofenceArea newArea) async {
    if (!_shouldNotify(newArea.id)) return;

    const title = '🔄 Area Updated';
    final body = 'Nearest service area changed to ${newArea.name}.';

    _pushToDashboard(
      areaId: newArea.id,
      areaName: newArea.name,
      title: title,
      body: body,
    );

    await _show(
      id: _notificationId(newArea.id),
      title: title,
      body: body,
    );

    _recordNotification(newArea.id);
  }

  /// Marks a single dashboard notification as read.
  void markAsRead(int id) {
    for (final item in _notifications) {
      if (item.id == id) {
        if (!item.isRead) {
          item.isRead = true;
          notifyListeners();
        }
        return;
      }
    }
  }

  /// Marks all dashboard notifications as read.
  void markAllAsRead() {
    bool changed = false;

    for (final item in _notifications) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Clears the dashboard notification history.
  void clearNotifications() {
    if (_notifications.isEmpty) return;
    _notifications.clear();
    notifyListeners();
  }

  // ── Cooldown / dedup logic ────────────────────────────────────────────

  /// Returns `true` if the area is eligible for a notification.
  bool _shouldNotify(String areaId) {
    // Same area as last notification → skip.
    if (_lastNotifiedAreaId == areaId) return false;

    // Cooldown check.
    final lastTime = _notificationTimestamps[areaId];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < cooldownDuration) return false;
    }

    return true;
  }

  void _recordNotification(String areaId) {
    _lastNotifiedAreaId = areaId;
    _notificationTimestamps[areaId] = DateTime.now();
  }

  // ── Internal ──────────────────────────────────────────────────────────

  void _pushToDashboard({
    required String areaId,
    required String areaName,
    required String title,
    required String body,
  }) {
    _notifications.insert(
      0,
      DashboardNotification(
        id: _eventId(),
        areaId: areaId,
        areaName: areaName,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );

    if (_notifications.length > _maxStoredNotifications) {
      _notifications.removeLast();
    }

    notifyListeners();
  }

  /// Generates a stable notification id from the area id hash so each area
  /// replaces its own previous notification instead of stacking.
  int _notificationId(String areaId) => areaId.hashCode.abs() % 100000;

  int _eventId() => DateTime.now().microsecondsSinceEpoch % 2147483647;

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'nagarwatch_geofence',
      'NagarWatch Location',
      channelDescription: 'Notifications for detected service areas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, notificationDetails);
    debugPrint('[NotificationHandler] Showed: $title — $body');
  }
}
