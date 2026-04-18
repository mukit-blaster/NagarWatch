// lib/features/geofencing_notifications/services/geofence_logic.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/geofence_model.dart';

// ─── Result class ────────────────────────────────────────────────────────────

/// Holds everything the provider needs after a detection run.
class GeofenceResult {
  final double latitude;
  final double longitude;
  final String readableAddress;
  final GeofenceArea nearestArea;
  final double distanceKm;

  /// True  → user is physically inside the area radius.
  /// False → fallback: nearest area selected even though user is outside.
  final bool isInsideRadius;

  const GeofenceResult({
    required this.latitude,
    required this.longitude,
    required this.readableAddress,
    required this.nearestArea,
    required this.distanceKm,
    required this.isInsideRadius,
  });
}

// ─── Exception types ─────────────────────────────────────────────────────────

class LocationServiceDisabledException implements Exception {
  final String message = 'Location services are disabled. Please enable GPS.';
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Location permission was denied.';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message =
      'Location permission is permanently denied. Please enable it from app settings.';
}

// ─── Service ─────────────────────────────────────────────────────────────────

class GeofenceLogic {
  /// Entry point: checks permission, gets location, finds nearest area.
  /// Throws typed exceptions on failure so the provider can surface
  /// user-friendly messages without parsing raw error strings.
  Future<GeofenceResult> detectArea({
    List<GeofenceArea> areas = BangladeshAreas.all,
  }) async {
    await _ensureLocationReady();

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final address = await _resolveAddress(
      position.latitude,
      position.longitude,
    );
    final detection = _findNearestArea(
      position.latitude,
      position.longitude,
      areas,
    );

    return GeofenceResult(
      latitude: position.latitude,
      longitude: position.longitude,
      readableAddress: address,
      nearestArea: detection.area,
      distanceKm: detection.distanceKm,
      isInsideRadius: detection.distanceKm <= detection.area.radiusKm,
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationServiceDisabledException();

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationPermissionDeniedException();
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return _fallbackCoords(lat, lng);

      final p = placemarks.first;
      final parts = <String>[
        if (p.subLocality?.isNotEmpty == true) p.subLocality!,
        if (p.locality?.isNotEmpty == true) p.locality!,
        if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
      ];
      return parts.isNotEmpty ? parts.join(', ') : _fallbackCoords(lat, lng);
    } catch (_) {
      return _fallbackCoords(lat, lng);
    }
  }

  String _fallbackCoords(double lat, double lng) =>
      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

  _AreaDistance _findNearestArea(
    double lat,
    double lng,
    List<GeofenceArea> areas,
  ) {
    assert(areas.isNotEmpty, 'Area list must not be empty');

    GeofenceArea? nearest;
    double smallestKm = double.infinity;

    for (final area in areas) {
      final meters = Geolocator.distanceBetween(
        lat,
        lng,
        area.centerLat,
        area.centerLng,
      );
      final km = meters / 1000.0;
      if (km < smallestKm) {
        smallestKm = km;
        nearest = area;
      }
    }

    return _AreaDistance(area: nearest!, distanceKm: smallestKm);
  }
}

// Small private helper — no need to expose outside this file.
class _AreaDistance {
  final GeofenceArea area;
  final double distanceKm;
  const _AreaDistance({required this.area, required this.distanceKm});
}
