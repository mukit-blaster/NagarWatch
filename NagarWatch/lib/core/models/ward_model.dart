class WardModel {
  final String id;
  final String name;
  final String district;
  final String upazila;
  final double centerLat;
  final double centerLng;
  final double radiusKm;

  const WardModel({
    required this.id,
    required this.name,
    required this.district,
    required this.upazila,
    required this.centerLat,
    required this.centerLng,
    this.radiusKm = 2.0,
  });

  factory WardModel.fromJson(Map<String, dynamic> json) => WardModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    district: json['district']?.toString() ?? '',
    upazila: json['upazila']?.toString() ?? '',
    centerLat: (json['centerLat'] as num?)?.toDouble() ?? 23.8103,
    centerLng: (json['centerLng'] as num?)?.toDouble() ?? 90.4125,
    radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 2.0,
  );

  String get displayName => '$name, $upazila, $district';

  static List<WardModel> get sampleWards => [
    const WardModel(id: 'ward_1', name: 'Ward 01 – Motijheel', district: 'Dhaka', upazila: 'Dhaka Sadar', centerLat: 23.7344, centerLng: 90.4197),
    const WardModel(id: 'ward_2', name: 'Ward 02 – Sabujbagh', district: 'Dhaka', upazila: 'Sabujbagh', centerLat: 23.7277, centerLng: 90.4372),
    const WardModel(id: 'ward_3', name: 'Ward 03 – Khilgaon', district: 'Dhaka', upazila: 'Khilgaon', centerLat: 23.7490, centerLng: 90.4282),
    const WardModel(id: 'ward_4', name: 'Ward 04 – Rampura', district: 'Dhaka', upazila: 'Rampura', centerLat: 23.7617, centerLng: 90.4250),
    const WardModel(id: 'ward_5', name: 'Ward 05 – Banasree', district: 'Dhaka', upazila: 'Rampura', centerLat: 23.7568, centerLng: 90.4388),
    const WardModel(id: 'ward_6', name: 'Ward 06 – Mirpur-1', district: 'Dhaka', upazila: 'Mirpur', centerLat: 23.7972, centerLng: 90.3624),
    const WardModel(id: 'ward_7', name: 'Ward 07 – Mirpur-10', district: 'Dhaka', upazila: 'Mirpur', centerLat: 23.8103, centerLng: 90.3681),
    const WardModel(id: 'ward_8', name: 'Ward 08 – Pallabi', district: 'Dhaka', upazila: 'Pallabi', centerLat: 23.8240, centerLng: 90.3572),
    const WardModel(id: 'ward_9', name: 'Ward 09 – Uttara', district: 'Dhaka', upazila: 'Uttara', centerLat: 23.8759, centerLng: 90.3795),
    const WardModel(id: 'ward_10', name: 'Ward 10 – Mohammadpur', district: 'Dhaka', upazila: 'Mohammadpur', centerLat: 23.7583, centerLng: 90.3597),
    const WardModel(id: 'ward_11', name: 'Ward 11 – Dhanmondi', district: 'Dhaka', upazila: 'Dhanmondi', centerLat: 23.7460, centerLng: 90.3740),
    const WardModel(id: 'ward_12', name: 'Ward 12 – Gulshan', district: 'Dhaka', upazila: 'Gulshan', centerLat: 23.7806, centerLng: 90.4141),
    const WardModel(id: 'ward_13', name: 'Ward 13 – Banani', district: 'Dhaka', upazila: 'Gulshan', centerLat: 23.7937, centerLng: 90.4066),
    const WardModel(id: 'ward_14', name: 'Ward 14 – Wari', district: 'Dhaka', upazila: 'Wari', centerLat: 23.7168, centerLng: 90.4101),
    const WardModel(id: 'ward_15', name: 'Ward 15 – Lalbagh', district: 'Dhaka', upazila: 'Lalbagh', centerLat: 23.7167, centerLng: 90.3897),
    const WardModel(id: 'ward_16', name: 'DIU Campus – Savar', district: 'Dhaka', upazila: 'Savar', centerLat: 23.7982, centerLng: 90.2709, radiusKm: 1.5),
  ];
}
