// lib/features/geofencing_notifications/models/geofence_model.dart

/// Immutable model representing a custom NagarWatch service area.
///
/// Each area is defined by a center coordinate and a radius (in km).
/// The system uses these to detect the nearest area relative to
/// the user's live GPS position — no polygon / GIS matching required.
class GeofenceArea {
  final String id;
  final String name;
  final String upazila;
  final String district;
  final double centerLat;
  final double centerLng;
  final double radiusKm;
  final String? description;

  const GeofenceArea({
    required this.id,
    required this.name,
    required this.upazila,
    required this.district,
    required this.centerLat,
    required this.centerLng,
    required this.radiusKm,
    this.description,
  });

  // ── Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'upazila': upazila,
    'district': district,
    'centerLat': centerLat,
    'centerLng': centerLng,
    'radiusKm': radiusKm,
    'description': description,
  };

  factory GeofenceArea.fromMap(Map<String, dynamic> map) {
    return GeofenceArea(
      id: map['id'] as String,
      name: map['name'] as String,
      upazila: map['upazila'] as String,
      district: map['district'] as String,
      centerLat: (map['centerLat'] as num).toDouble(),
      centerLng: (map['centerLng'] as num).toDouble(),
      radiusKm: (map['radiusKm'] as num).toDouble(),
      description: map['description'] as String?,
    );
  }

  // ── Display helpers ────────────────────────────────────────────────────

  /// Short label: "DIU Campus Area"
  String get displayName => name;

  /// Full label: "DIU Campus Area, Savar, Dhaka"
  String get fullLabel => '$name, $upazila, $district';

  String get fullDisplayName => fullLabel;

  @override
  String toString() => fullLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GeofenceArea && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ═══════════════════════════════════════════════════════════════════════════
// BUILT-IN BANGLADESH SERVICE AREAS
// ═══════════════════════════════════════════════════════════════════════════
//
// Realistic custom areas covering major Dhaka-region localities.
// Center coordinates are approximate real-world points for each area.
// Radius values range from 0.8 km (small campus) to 3.0 km (large zone).
//
// Structure: Savar ➜ Ashulia ➜ Dhaka city ➜ Mirpur ➜ Uttara ➜ Bashundhara
// ═══════════════════════════════════════════════════════════════════════════

class BangladeshAreas {
  BangladeshAreas._(); // prevent instantiation

  static const List<GeofenceArea> all = [
    // ── Savar / DIU side ───────────────────────────────────────────────
    GeofenceArea(
      id: 'diu_campus',
      name: 'DIU Campus Area',
      upazila: 'Savar',
      district: 'Dhaka',
      centerLat: 23.8763,
      centerLng: 90.3200,
      radiusKm: 1.0,
      description: 'Daffodil International University permanent campus zone',
    ),
    GeofenceArea(
      id: 'ju_area',
      name: 'Jahangirnagar University Area',
      upazila: 'Savar',
      district: 'Dhaka',
      centerLat: 23.8787,
      centerLng: 90.2672,
      radiusKm: 2.0,
      description: 'Jahangirnagar University campus and surroundings',
    ),
    GeofenceArea(
      id: 'nabinagar',
      name: 'Nabinagar Area',
      upazila: 'Savar',
      district: 'Dhaka',
      centerLat: 23.8655,
      centerLng: 90.3095,
      radiusKm: 1.5,
      description: 'Nabinagar housing and residential zone',
    ),
    GeofenceArea(
      id: 'savar_bazar',
      name: 'Savar Bazar Area',
      upazila: 'Savar',
      district: 'Dhaka',
      centerLat: 23.8448,
      centerLng: 90.2555,
      radiusKm: 1.8,
      description: 'Savar central bazar and commercial hub',
    ),
    GeofenceArea(
      id: 'hemayetpur',
      name: 'Hemayetpur Area',
      upazila: 'Savar',
      district: 'Dhaka',
      centerLat: 23.8120,
      centerLng: 90.2450,
      radiusKm: 2.0,
      description: 'Hemayetpur residential and industrial zone',
    ),

    // ── Ashulia side ───────────────────────────────────────────────────
    GeofenceArea(
      id: 'ashulia_zone',
      name: 'Ashulia Zone',
      upazila: 'Ashulia',
      district: 'Dhaka',
      centerLat: 23.8957,
      centerLng: 90.3390,
      radiusKm: 2.5,
      description: 'Ashulia industrial and residential zone',
    ),
    GeofenceArea(
      id: 'epz_area',
      name: 'EPZ Area',
      upazila: 'Ashulia',
      district: 'Dhaka',
      centerLat: 23.9130,
      centerLng: 90.3250,
      radiusKm: 1.5,
      description: 'Dhaka Export Processing Zone',
    ),
    GeofenceArea(
      id: 'baipail',
      name: 'Baipail Area',
      upazila: 'Ashulia',
      district: 'Dhaka',
      centerLat: 23.9075,
      centerLng: 90.3540,
      radiusKm: 1.2,
      description: 'Baipail residential area near Ashulia',
    ),
    GeofenceArea(
      id: 'zirabo',
      name: 'Zirabo Area',
      upazila: 'Ashulia',
      district: 'Dhaka',
      centerLat: 23.9185,
      centerLng: 90.3105,
      radiusKm: 1.5,
      description: 'Zirabo garment zone and residential area',
    ),

    // ── Dhaka city ─────────────────────────────────────────────────────
    GeofenceArea(
      id: 'dhanmondi_27',
      name: 'Dhanmondi 27 Area',
      upazila: 'Dhanmondi',
      district: 'Dhaka',
      centerLat: 23.7461,
      centerLng: 90.3742,
      radiusKm: 1.2,
      description: 'Dhanmondi 27 number and Shangkar zone',
    ),
    GeofenceArea(
      id: 'jigatola',
      name: 'Jigatola Area',
      upazila: 'Dhanmondi',
      district: 'Dhaka',
      centerLat: 23.7390,
      centerLng: 90.3755,
      radiusKm: 1.0,
      description: 'Jigatola bus stand and surrounding area',
    ),
    GeofenceArea(
      id: 'mohammadpur',
      name: 'Mohammadpur Town Hall Area',
      upazila: 'Mohammadpur',
      district: 'Dhaka',
      centerLat: 23.7650,
      centerLng: 90.3585,
      radiusKm: 1.5,
      description: 'Mohammadpur Town Hall and Krishi Market area',
    ),
    GeofenceArea(
      id: 'farmgate',
      name: 'Farmgate Area',
      upazila: 'Tejgaon',
      district: 'Dhaka',
      centerLat: 23.7574,
      centerLng: 90.3870,
      radiusKm: 1.0,
      description: 'Farmgate intersection and commercial zone',
    ),
    GeofenceArea(
      id: 'shahbagh',
      name: 'Shahbagh Area',
      upazila: 'Ramna',
      district: 'Dhaka',
      centerLat: 23.7389,
      centerLng: 90.3954,
      radiusKm: 1.0,
      description: 'Shahbagh intersection and Dhaka University vicinity',
    ),
    GeofenceArea(
      id: 'motijheel',
      name: 'Motijheel Commercial Area',
      upazila: 'Motijheel',
      district: 'Dhaka',
      centerLat: 23.7326,
      centerLng: 90.4194,
      radiusKm: 1.5,
      description: 'Motijheel banking and commercial district',
    ),

    // ── Mirpur / Pallabi ───────────────────────────────────────────────
    GeofenceArea(
      id: 'mirpur_10',
      name: 'Mirpur 10 Area',
      upazila: 'Mirpur',
      district: 'Dhaka',
      centerLat: 23.8069,
      centerLng: 90.3687,
      radiusKm: 1.5,
      description: 'Mirpur 10 roundabout and Mirpur Stadium area',
    ),
    GeofenceArea(
      id: 'pallabi',
      name: 'Pallabi Area',
      upazila: 'Pallabi',
      district: 'Dhaka',
      centerLat: 23.8270,
      centerLng: 90.3650,
      radiusKm: 1.8,
      description: 'Pallabi residential zone',
    ),
    GeofenceArea(
      id: 'kazipara',
      name: 'Kazipara Area',
      upazila: 'Mirpur',
      district: 'Dhaka',
      centerLat: 23.7960,
      centerLng: 90.3720,
      radiusKm: 1.0,
      description: 'Kazipara market and residential area',
    ),
    GeofenceArea(
      id: 'shewrapara',
      name: 'Shewrapara Area',
      upazila: 'Mirpur',
      district: 'Dhaka',
      centerLat: 23.7900,
      centerLng: 90.3770,
      radiusKm: 1.0,
      description: 'Shewrapara metro station zone',
    ),

    // ── Uttara / Airport ───────────────────────────────────────────────
    GeofenceArea(
      id: 'uttara_7',
      name: 'Uttara Sector 7 Area',
      upazila: 'Uttara',
      district: 'Dhaka',
      centerLat: 23.8680,
      centerLng: 90.3910,
      radiusKm: 1.5,
      description: 'Uttara Sector 7 and Rajlokkhi area',
    ),
    GeofenceArea(
      id: 'uttara_10',
      name: 'Uttara Sector 10 Area',
      upazila: 'Uttara',
      district: 'Dhaka',
      centerLat: 23.8760,
      centerLng: 90.3930,
      radiusKm: 1.2,
      description: 'Uttara Sector 10 residential zone',
    ),
    GeofenceArea(
      id: 'airport_station',
      name: 'Airport Station Area',
      upazila: 'Uttara',
      district: 'Dhaka',
      centerLat: 23.8512,
      centerLng: 90.4078,
      radiusKm: 2.0,
      description: 'Shahjalal Airport and surrounding area',
    ),

    // ── Bashundhara / Gulshan / Badda ──────────────────────────────────
    GeofenceArea(
      id: 'bashundhara',
      name: 'Bashundhara R/A',
      upazila: 'Vatara',
      district: 'Dhaka',
      centerLat: 23.8150,
      centerLng: 90.4270,
      radiusKm: 2.5,
      description: 'Bashundhara Residential Area and shopping complex',
    ),
    GeofenceArea(
      id: 'gulshan_1',
      name: 'Gulshan 1 Area',
      upazila: 'Gulshan',
      district: 'Dhaka',
      centerLat: 23.7808,
      centerLng: 90.4168,
      radiusKm: 1.2,
      description: 'Gulshan 1 circle and diplomatic zone',
    ),
    GeofenceArea(
      id: 'gulshan_2',
      name: 'Gulshan 2 Area',
      upazila: 'Gulshan',
      district: 'Dhaka',
      centerLat: 23.7935,
      centerLng: 90.4145,
      radiusKm: 1.2,
      description: 'Gulshan 2 circle and commercial area',
    ),
    GeofenceArea(
      id: 'banani',
      name: 'Banani Area',
      upazila: 'Banani',
      district: 'Dhaka',
      centerLat: 23.7940,
      centerLng: 90.4030,
      radiusKm: 1.5,
      description: 'Banani residential and commercial zone',
    ),
    GeofenceArea(
      id: 'badda',
      name: 'Merul Badda Area',
      upazila: 'Badda',
      district: 'Dhaka',
      centerLat: 23.7805,
      centerLng: 90.4265,
      radiusKm: 1.5,
      description: 'Merul Badda residential area',
    ),
  ];
}
