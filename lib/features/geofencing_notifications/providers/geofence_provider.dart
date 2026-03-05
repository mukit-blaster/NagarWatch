import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/geofence_model.dart';
import '../services/geofence_logic.dart';
import '../services/notification_handler.dart';

class GeofenceProvider extends ChangeNotifier {
  bool _isDetectingLocation = false;
  String _locationStatusText = 'Detecting location…';
  String? _addressText;
  String? _coordsText;

  Position? _pos;
  StreamSubscription<Position>? _posSub;

  List<WardModel> _wards = [];
  List<WardModel> _visibleWards = [];
  WardModel? _selectedWard;

  bool? _wasInsideSelected;

  bool get isDetectingLocation => _isDetectingLocation;
  String get locationStatusText => _locationStatusText;
  String? get addressText => _addressText;
  String? get coordsText => _coordsText;

  double? get userLat => _pos?.latitude;
  double? get userLng => _pos?.longitude;

  List<WardModel> get visibleWards => _visibleWards;
  WardModel? get selectedWard => _selectedWard;

  Future<void> initialize() async {
    _wards = _fallbackSampleWards(center: const LatLng(23.8103, 90.4125));
    _visibleWards = List.of(_wards);
    notifyListeners();

    await detectLocation(force: true);
    _startLocationStream();
  }

  Future<void> detectLocation({bool force = false}) async {
    if (_isDetectingLocation && !force) return;

    _isDetectingLocation = true;
    _locationStatusText = 'Detecting location…';
    notifyListeners();

    try {
      final ok = await _ensureLocationReady();
      if (!ok) {
        _locationStatusText = 'Location permission required';
        return;
      }

      _pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _coordsText = _formatLatLng(_pos!.latitude, _pos!.longitude);
      notifyListeners();

      final nom =
          await _reverseGeocodeNominatim(_pos!.latitude, _pos!.longitude);

      _addressText = nom.shortAddress ?? 'Unknown location';
      _locationStatusText = 'Location detected';

      final osmWards =
          await _fetchNearbyWardsFromOverpass(_pos!.latitude, _pos!.longitude);
      if (osmWards.isNotEmpty) {
        _wards = osmWards;
      } else {
        _wards = _fallbackSampleWards(
            center: LatLng(_pos!.latitude, _pos!.longitude));
      }

      _visibleWards = _sortedByDistance(_wards);

      // Auto select nearest ward
      if (_visibleWards.isNotEmpty) {
        selectWard(_visibleWards.first, notify: false);
      }

      notifyListeners();
    } catch (e) {
      _locationStatusText = 'Failed to detect location';
      if (kDebugMode) debugPrint('detectLocation error: $e');
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }

  void filterWards(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _visibleWards = _sortedByDistance(_wards);
    } else {
      _visibleWards = _sortedByDistance(
        _wards
            .where((w) =>
                w.title.toLowerCase().contains(q) ||
                w.name.toLowerCase().contains(q) ||
                w.zone.toLowerCase().contains(q))
            .toList(),
      );
    }
    notifyListeners();
  }

  void selectWard(WardModel ward, {bool notify = true}) {
    _selectedWard = ward;
    _wasInsideSelected = null;
    if (notify) notifyListeners();
  }

  String distanceTextForWard(WardModel w) {
    if (_pos == null) return '—';
    final d = GeofenceLogic.distanceMeters(
      lat1: _pos!.latitude,
      lon1: _pos!.longitude,
      lat2: w.center.latitude,
      lon2: w.center.longitude,
    );
    if (d < 1000) return '${d.toStringAsFixed(0)} m';
    return '${(d / 1000).toStringAsFixed(1)} km';
  }

  void _startLocationStream() {
    _posSub?.cancel();
    const settings =
        LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10);

    _posSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((p) async {
      _pos = p;
      _coordsText = _formatLatLng(p.latitude, p.longitude);

      final sw = _selectedWard;
      if (sw != null) {
        final inside = GeofenceLogic.isInside(
          userLat: p.latitude,
          userLon: p.longitude,
          centerLat: sw.center.latitude,
          centerLon: sw.center.longitude,
          radiusMeters: sw.radiusMeters,
        );

        if (_wasInsideSelected == null) {
          _wasInsideSelected = inside;
        } else if (_wasInsideSelected != inside) {
          _wasInsideSelected = inside;
          await NotificationHandler.instance.showGeofenceNotification(
            title: inside ? '✅ Entered ${sw.title}' : '⚠️ Left ${sw.title}',
            body: inside
                ? 'Inside selected ward geofence.'
                : 'Outside selected ward geofence.',
          );
        }
      }

      _visibleWards = _sortedByDistance(_visibleWards);
      notifyListeners();
    });
  }

  Future<bool> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  List<WardModel> _sortedByDistance(List<WardModel> list) {
    if (_pos == null) return List.of(list);
    final copy = List.of(list);
    copy.sort((a, b) {
      final da = GeofenceLogic.distanceMeters(
        lat1: _pos!.latitude,
        lon1: _pos!.longitude,
        lat2: a.center.latitude,
        lon2: a.center.longitude,
      );
      final db = GeofenceLogic.distanceMeters(
        lat1: _pos!.latitude,
        lon1: _pos!.longitude,
        lat2: b.center.latitude,
        lon2: b.center.longitude,
      );
      return da.compareTo(db);
    });
    return copy;
  }

  String _formatLatLng(double lat, double lng) {
    final ns = lat >= 0 ? 'N' : 'S';
    final ew = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $ns, ${lng.abs().toStringAsFixed(4)}° $ew';
  }

  Future<_NominatimResult> _reverseGeocodeNominatim(
      double lat, double lon) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': lat.toString(),
      'lon': lon.toString(),
      'zoom': '18',
      'addressdetails': '1',
    });

    final res = await http.get(
      uri,
      headers: {
        'User-Agent': 'NagarWatch/1.0',
        'Accept-Language': 'en',
      },
    ).timeout(const Duration(seconds: 12));

    if (res.statusCode != 200) return const _NominatimResult();

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final addr = (j['address'] as Map?)?.cast<String, dynamic>() ?? {};

    // ✅ FIX: List<String?> then clean -> List<String>
    final rawParts = <String?>[
      (addr['suburb'] ??
              addr['neighbourhood'] ??
              addr['hamlet'] ??
              addr['quarter'])
          ?.toString(),
      (addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['municipality'])
          ?.toString(),
      (addr['state'] ?? addr['region'])?.toString(),
      (addr['country'])?.toString(),
    ];

    final parts = rawParts
        .where((s) => s != null && s!.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();

    final shortAddress =
        parts.isNotEmpty ? parts.join(', ') : (j['display_name']?.toString());

    final wardName = (addr['ward'] ?? addr['city_district'])?.toString();

    return _NominatimResult(shortAddress: shortAddress, wardName: wardName);
  }

  Future<List<WardModel>> _fetchNearbyWardsFromOverpass(
      double lat, double lon) async {
    const endpoint = 'https://overpass-api.de/api/interpreter';

    final query = '''
[out:json][timeout:20];
(
  relation(around:5000,$lat,$lon)["boundary"="administrative"]["admin_level"~"10|11"];
);
out tags center;
''';

    try {
      final res = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'text/plain; charset=utf-8',
              'User-Agent': 'NagarWatch/1.0',
            },
            body: query,
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return [];

      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final elements = (j['elements'] as List?) ?? [];

      final wards = <WardModel>[];
      int fallbackNumber = 1;

      for (final el in elements) {
        if (el is! Map<String, dynamic>) continue;
        final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = (tags['name:en'] ?? tags['name'])?.toString();
        final adminLevel = tags['admin_level']?.toString();

        if (name == null || name.trim().isEmpty) continue;

        final nameL = name.toLowerCase();
        if (!(nameL.contains('ward') || nameL.contains('ওয়ার্ড'))) continue;

        final centerLat = (el['center']?['lat'] as num?)?.toDouble();
        final centerLon = (el['center']?['lon'] as num?)?.toDouble();
        if (centerLat == null || centerLon == null) continue;

        final n = _extractWardNumber(name) ?? fallbackNumber++;

        wards.add(
          WardModel(
            id: 'osm_${el['id']}',
            number: n,
            name: name,
            zone: 'Admin L$adminLevel',
            projects: 0,
            center: LatLng(centerLat, centerLon),
            radiusMeters: 450,
            pinColor: const Color(0xFF1E3A8A),
            iconColor: const Color(0xFF1E3A8A),
            iconBgColor: const Color(0xFFEFF6FF),
          ),
        );
      }

      // unique by name
      final seen = <String>{};
      final unique = <WardModel>[];
      for (final w in wards) {
        final k = w.name.toLowerCase();
        if (seen.add(k)) unique.add(w);
      }

      unique.sort((a, b) {
        final da = GeofenceLogic.distanceMeters(
            lat1: lat,
            lon1: lon,
            lat2: a.center.latitude,
            lon2: a.center.longitude);
        final db = GeofenceLogic.distanceMeters(
            lat1: lat,
            lon1: lon,
            lat2: b.center.latitude,
            lon2: b.center.longitude);
        return da.compareTo(db);
      });

      return unique.take(20).toList();
    } catch (_) {
      return [];
    }
  }

  int? _extractWardNumber(String s) {
    final m = RegExp(r'(\d{1,3})').firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }

  List<WardModel> _fallbackSampleWards({required LatLng center}) {
    const primary = Color(0xFF1E3A8A);
    const accent = Color(0xFF059669);
    const warning = Color(0xFFF59E0B);
    const danger = Color(0xFFEF4444);

    return [
      WardModel(
        id: 'w12',
        number: 12,
        name: 'Your Area',
        zone: 'Central Zone',
        projects: 24,
        center: LatLng(center.latitude + 0.0016, center.longitude - 0.0012),
        radiusMeters: 400,
        pinColor: primary,
        iconColor: primary,
        iconBgColor: const Color(0xFFEFF6FF),
      ),
      WardModel(
        id: 'w7',
        number: 7,
        name: 'Nearby Zone',
        zone: 'North Zone',
        projects: 18,
        center: LatLng(center.latitude + 0.0034, center.longitude + 0.0014),
        radiusMeters: 450,
        pinColor: accent,
        iconColor: accent,
        iconBgColor: const Color(0xFFECFDF5),
      ),
      WardModel(
        id: 'w3',
        number: 3,
        name: 'Neighbor Ward',
        zone: 'South Zone',
        projects: 31,
        center: LatLng(center.latitude - 0.0030, center.longitude - 0.0026),
        radiusMeters: 500,
        pinColor: warning,
        iconColor: warning,
        iconBgColor: const Color(0xFFFFFBEB),
      ),
      WardModel(
        id: 'w19',
        number: 19,
        name: 'Outer Ward',
        zone: 'East Zone',
        projects: 12,
        center: LatLng(center.latitude - 0.0018, center.longitude + 0.0035),
        radiusMeters: 550,
        pinColor: danger,
        iconColor: danger,
        iconBgColor: const Color(0xFFFEF2F2),
      ),
    ];
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }
}

class _NominatimResult {
  final String? shortAddress;
  final String? wardName;
  const _NominatimResult({this.shortAddress, this.wardName});
}
