class EvidenceModel {
  final String id;
  final String projectId;
  final String? projectName;
  final String? description;
  final String uploadedBy;
  final String uploaderName;
  final String? wardId;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; // pending | verified | rejected
  final String? rejectionReason;
  final String? issueId;

  const EvidenceModel({
    required this.id,
    required this.projectId,
    this.projectName,
    this.description,
    required this.uploadedBy,
    required this.uploaderName,
    this.wardId,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = 'pending',
    this.rejectionReason,
    this.issueId,
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) => EvidenceModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    projectId: json['projectId']?.toString() ?? '',
    projectName: json['projectName']?.toString(),
    description: json['description']?.toString(),
    uploadedBy: json['uploadedBy']?.toString() ?? '',
    uploaderName: json['uploaderName']?.toString() ?? '',
    wardId: json['wardId']?.toString(),
    imageUrl: json['imageUrl']?.toString() ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    status: json['status']?.toString() ?? 'pending',
    rejectionReason: json['rejectionReason']?.toString(),
    issueId: json['issueId']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    if (projectName != null) 'projectName': projectName,
    if (description != null) 'description': description,
    'uploadedBy': uploadedBy,
    'uploaderName': uploaderName,
    if (wardId != null) 'wardId': wardId,
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (issueId != null) 'issueId': issueId,
  };
}
