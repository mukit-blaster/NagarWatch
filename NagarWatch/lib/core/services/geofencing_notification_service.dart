import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../models/issue_model.dart';
import 'notification_service.dart';

/// Geofencing service that monitors user location and triggers notifications
/// when the user enters areas with active projects or issues.
///
/// Features:
/// • Continuous background location monitoring
/// • Configurable update intervals
/// • Smart notification cooldowns
/// • Area-based filtering for relevant updates
class GeofencingNotificationService {
  GeofencingNotificationService._();
  static final GeofencingNotificationService instance =
      GeofencingNotificationService._();

  // Location monitoring
  StreamSubscription<Position>? _positionStream;
  Position? _lastKnownPosition;
  bool _isMonitoring = false;

  // Notification tracking
  final Map<String, DateTime> _lastNotificationTime = {};
  static const Duration _notificationCooldown = Duration(minutes: 15);

  // Geofence areas (in km)
  static const double _defaultGeofenceRadius = 5.0;

  // ── Initialisation ────────────────────────────────────────────────────

  /// Start monitoring user location for geofence events
  /// 
  /// Parameters:
  /// • [accuracy]: Location accuracy level (default: high)
  /// • [distanceFilter]: Minimum distance change to trigger update (meters, default: 100)
  /// • [intervalMs]: Update interval in milliseconds (default: 5000)
  Future<void> startMonitoring({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 100,
    int intervalMs = 5000,
  }) async {
    if (_isMonitoring) return;

    try {
      // Check location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[GeofencingNotificationService] Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            '[GeofencingNotificationService] Location permission permanently denied');
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[GeofencingNotificationService] Location services disabled');
        return;
      }

      _isMonitoring = true;

      // Start listening to position changes
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          debugPrint(
              '[GeofencingNotificationService] Position: ${position.latitude}, ${position.longitude}');
        },
        onError: (e) {
          debugPrint('[GeofencingNotificationService] Location error: $e');
          _isMonitoring = false;
        },
      );

      debugPrint('[GeofencingNotificationService] Started monitoring');
    } catch (e) {
      debugPrint('[GeofencingNotificationService] Error starting monitoring: $e');
      _isMonitoring = false;
    }
  }

  /// Stop monitoring user location
  Future<void> stopMonitoring() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isMonitoring = false;
    debugPrint('[GeofencingNotificationService] Stopped monitoring');
  }

  /// Get current monitoring status
  bool get isMonitoring => _isMonitoring;

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  // ── Public API ────────────────────────────────────────────────────────

  /// Check if user is within a geofence of an issue location
  /// 
  /// Returns true if user is within [radiusKm] of the issue location
  Future<bool> isUserNearIssue(
    IssueModel issue, {
    double radiusKm = _defaultGeofenceRadius,
  }) async {
    if (issue.latitude == null || issue.longitude == null) {
      return false;
    }

    if (_lastKnownPosition == null) {
      // Get current position if not already cached
      try {
        _lastKnownPosition = await Geolocator.getCurrentPosition();
      } catch (e) {
        debugPrint(
            '[GeofencingNotificationService] Error getting position: $e');
        return false;
      }
    }

    if (_lastKnownPosition == null) return false;

    final distance = Geolocator.distanceBetween(
      _lastKnownPosition!.latitude,
      _lastKnownPosition!.longitude,
      issue.latitude!,
      issue.longitude!,
    );

    final distanceKm = distance / 1000;
    return distanceKm <= radiusKm;
  }

  /// Notify user about an issue if they're nearby
  /// 
  /// Returns true if notification was sent, false if cooldown is active
  Future<bool> notifyNearbyIssue(
    IssueModel issue, {
    double radiusKm = _defaultGeofenceRadius,
  }) async {
    final notificationId = 'issue_${issue.id}';

    // Check cooldown
    final lastTime = _lastNotificationTime[notificationId];
    if (lastTime != null &&
        DateTime.now().difference(lastTime) < _notificationCooldown) {
      debugPrint(
          '[GeofencingNotificationService] Notification on cooldown: $notificationId');
      return false;
    }

    // Check if user is nearby
    final isNear = await isUserNearIssue(issue, radiusKm: radiusKm);
    if (!isNear) {
      return false;
    }

    // Send notification
    await NotificationService.instance.show(
      id: notificationId,
      title: '📍 Issue Nearby: ${issue.title}',
      body:
          '${issue.areaName} | Status: ${issue.status.name} | Distance: ${_calculateDistance(issue).toStringAsFixed(1)} km',
    );

    _lastNotificationTime[notificationId] = DateTime.now();
    debugPrint(
        '[GeofencingNotificationService] Notified about nearby issue: ${issue.title}');

    return true;
  }

  /// Notify about multiple issues and filter those nearby
  Future<List<IssueModel>> filterNearbyIssues(
    List<IssueModel> issues, {
    double radiusKm = _defaultGeofenceRadius,
  }) async {
    final nearbyIssues = <IssueModel>[];

    for (final issue in issues) {
      final isNear = await isUserNearIssue(issue, radiusKm: radiusKm);
      if (isNear) {
        nearbyIssues.add(issue);
      }
    }

    return nearbyIssues;
  }

  /// Clear notification cooldown for an issue
  void clearNotificationCooldown(String issueId) {
    _lastNotificationTime.remove('issue_$issueId');
  }

  /// Clear all notification cooldowns
  void clearAllCooldowns() {
    _lastNotificationTime.clear();
  }

  // ── Private Helpers ──────────────────────────────────────────────────

  /// Calculate distance between current position and issue location (in km)
  double _calculateDistance(IssueModel issue) {
    if (_lastKnownPosition == null || issue.latitude == null || issue.longitude == null) {
      return 0;
    }

    final distance = Geolocator.distanceBetween(
      _lastKnownPosition!.latitude,
      _lastKnownPosition!.longitude,
      issue.latitude!,
      issue.longitude!,
    );

    return distance / 1000;
  }

  /// Request location permissions
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check location service availability
  static Future<bool> isLocationServiceAvailable() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
