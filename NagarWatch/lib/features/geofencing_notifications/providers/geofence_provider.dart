// lib/features/geofencing_notifications/providers/geofence_provider.dart

import 'package:flutter/foundation.dart';
import '../models/geofence_model.dart';
import '../services/geofence_logic.dart';
import '../services/notification_handler.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PERMISSION STATE
// ═════════════════════════════════════════════════════════════════════════════

/// Represents the current location-permission state for the UI to react to.
enum GeofencePermissionState {
  /// Initial / unknown — no detection attempted yet.
  unknown,

  /// Permission granted — detection can proceed.
  granted,

  /// User tapped "Deny" on the permission dialog.
  denied,

  /// User permanently denied location permission.
  permanentlyDenied,

  /// Device GPS / location service is turned off.
  serviceDisabled,
}

// ═════════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═════════════════════════════════════════════════════════════════════════════

/// Central state holder and controller for the geofencing feature.
///
/// Exposes all the state a UI screen needs: loading, error, permission,
/// detected position, selected area, distance, and inside/outside status.
///
/// The constructor accepts optional [GeofenceLogic] and [NotificationHandler]
/// for easy unit-testing / mocking.
class GeofenceProvider extends ChangeNotifier {
  GeofenceProvider({
    GeofenceLogic? logic,
    NotificationHandler? notificationHandler,
  }) : _logic = logic ?? GeofenceLogic(),
       _notifications = notificationHandler ?? NotificationHandler.instance;

  final GeofenceLogic _logic;
  final NotificationHandler _notifications;

  // ── Observable state ─────────────────────────────────────────────────

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GeofencePermissionState _permissionState = GeofencePermissionState.unknown;
  GeofencePermissionState get permissionState => _permissionState;

  double? _latitude;
  double? get latitude => _latitude;

  double? _longitude;
  double? get longitude => _longitude;

  String _detectedAddress = '';
  String get detectedAddress => _detectedAddress;

  GeofenceArea? _selectedArea;
  GeofenceArea? get selectedArea => _selectedArea;

  double? _distanceKm;
  double? get distanceKm => _distanceKm;

  /// `true` → user is physically inside the selected area's radius.
  /// `false` → fallback selection (nearest but outside all configured radii).
  bool _isInsideRadius = false;
  bool get isInsideRadius => _isInsideRadius;

  /// `true` after a successful GPS detection has occurred at least once.
  bool _hasDetected = false;
  bool get hasDetected => _hasDetected;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Convenience getter: do we have a valid detection result to display?
  bool get hasResult => _selectedArea != null && _latitude != null;

  /// All available service areas (for building the selection list in UI).
  List<GeofenceArea> get availableAreas => BangladeshAreas.all;

  // ── Lifecycle ────────────────────────────────────────────────────────

  /// Call once during widget/screen initialization.
  /// Sets up local notifications. Safe to call multiple times.
  Future<void> initialize() async {
    await _notifications.initialize();
  }

  // ── Core detection ───────────────────────────────────────────────────

  /// Requests permission → gets GPS position → selects nearest area →
  /// updates state → optionally triggers a local notification.
  Future<void> detectCurrentArea() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _logic.detectArea();

      // Update all state fields at once before notifying.
      _permissionState = GeofencePermissionState.granted;
      _latitude = result.latitude;
      _longitude = result.longitude;
      _detectedAddress = result.readableAddress;
      _distanceKm = result.distanceKm;
      _isInsideRadius = result.isInsideRadius;

      final previousArea = _selectedArea;
      _selectedArea = result.nearestArea;
      _hasDetected = true;

      // Trigger notification on first detection or area change.
      if (previousArea == null) {
        await _notifications.showAreaDetected(result.nearestArea);
      } else if (previousArea.id != result.nearestArea.id) {
        await _notifications.showAreaChanged(result.nearestArea);
      }
    } on LocationServiceDisabledException catch (e) {
      _permissionState = GeofencePermissionState.serviceDisabled;
      _errorMessage = e.message;
    } on LocationPermissionPermanentlyDeniedException catch (e) {
      _permissionState = GeofencePermissionState.permanentlyDenied;
      _errorMessage = e.message;
    } on LocationPermissionDeniedException catch (e) {
      _permissionState = GeofencePermissionState.denied;
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage =
          'Something went wrong while detecting your location. '
          'Please try again.';
      debugPrint('[GeofenceProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── Manual selection ─────────────────────────────────────────────────

  /// Allows the user to manually pick an area from the list.
  /// Sets [isInsideRadius] to `false` because this is not GPS-confirmed.
  void selectAreaManually(GeofenceArea area) {
    _selectedArea = area;
    _isInsideRadius = false;
    _distanceKm = null; // distance is unknown for manual selection
    _clearError();
    notifyListeners();
  }

  // ── Error management ─────────────────────────────────────────────────

  /// Clears the current error message and notifies listeners.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
