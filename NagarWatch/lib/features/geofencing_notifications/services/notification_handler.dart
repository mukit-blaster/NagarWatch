// lib/features/geofencing_notifications/services/notification_handler.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/geofence_model.dart';

/// Lightweight wrapper around [FlutterLocalNotificationsPlugin] for
/// NagarWatch geofence-related notifications.
///
/// Features:
/// • Singleton so the plugin is initialised only once across the app.
/// • Duplicate-spam prevention — won't re-notify for the same area id.
/// • Time-based cooldown — won't re-notify for a previously notified area
///   until [cooldownDuration] has elapsed (FR-3.4).
class NotificationHandler {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Tracks the last notified area id to prevent immediate duplicates.
  String? _lastNotifiedAreaId;

  /// Tracks timestamps of the last notification per area id for cooldown.
  final Map<String, DateTime> _notificationTimestamps = {};

  /// Minimum interval before re-notifying the same area.
  static const Duration cooldownDuration = Duration(minutes: 30);

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
    _initialized = true;
    debugPrint('[NotificationHandler] Initialised successfully.');
  }

  // ── Public API ────────────────────────────────────────────────────────

  /// Shows a notification when an area is detected for the first time.
  Future<void> showAreaDetected(GeofenceArea area) async {
    if (!_shouldNotify(area.id)) return;

    await _show(
      id: _notificationId(area.id),
      title: '📍 Area Detected',
      body: 'You are near ${area.name}, ${area.upazila}, ${area.district}.',
    );

    _recordNotification(area.id);
  }

  /// Shows a notification when the detected area changes from one to another.
  Future<void> showAreaChanged(GeofenceArea newArea) async {
    if (!_shouldNotify(newArea.id)) return;

    await _show(
      id: _notificationId(newArea.id),
      title: '🔄 Area Updated',
      body: 'Nearest service area changed to ${newArea.name}.',
    );

    _recordNotification(newArea.id);
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

  /// Generates a stable notification id from the area id hash so each area
  /// replaces its own previous notification instead of stacking.
  int _notificationId(String areaId) => areaId.hashCode.abs() % 100000;

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'nagarwatch_geofence', // channel id
      'NagarWatch Location', // channel name
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
