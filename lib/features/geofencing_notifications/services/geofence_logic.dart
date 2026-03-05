import 'dart:math' as math;

class GeofenceLogic {
  static double distanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const r = 6371000.0; // meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static bool isInside({
    required double userLat,
    required double userLon,
    required double centerLat,
    required double centerLon,
    required double radiusMeters,
  }) {
    final d = distanceMeters(
        lat1: userLat, lon1: userLon, lat2: centerLat, lon2: centerLon);
    return d <= radiusMeters;
  }

  static double _degToRad(double d) => d * (math.pi / 180.0);
}
