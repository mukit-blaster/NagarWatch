import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class WardModel {
  final String id;
  final int number;
  final String name;
  final String zone;
  final int projects;

  /// Center point for map marker + geofence circle logic
  final LatLng center;

  /// Geofence radius (meters)
  final double radiusMeters;

  /// UI colors (pins + icons)
  final Color pinColor;
  final Color iconColor;
  final Color iconBgColor;

  const WardModel({
    required this.id,
    required this.number,
    required this.name,
    required this.zone,
    required this.projects,
    required this.center,
    required this.radiusMeters,
    required this.pinColor,
    required this.iconColor,
    required this.iconBgColor,
  });

  String get title => 'Ward $number – $name';

  WardModel copyWith({
    String? id,
    int? number,
    String? name,
    String? zone,
    int? projects,
    LatLng? center,
    double? radiusMeters,
    Color? pinColor,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return WardModel(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      projects: projects ?? this.projects,
      center: center ?? this.center,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      pinColor: pinColor ?? this.pinColor,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
    );
  }
}
