enum IssueStatus { submitted, inProgress, resolved }

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String areaName;
  final String roadNumber;
  final String? wardNumber;
  final String? wardId;
  final String? reportedBy;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  IssueStatus status;

  IssueModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.areaName,
    required this.roadNumber,
    this.wardNumber,
    this.wardId,
    this.reportedBy,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.status = IssueStatus.submitted,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) => IssueModel(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString(),
    areaName: json['areaName']?.toString() ?? '',
    roadNumber: json['roadNumber']?.toString() ?? '',
    wardNumber: json['wardNumber']?.toString(),
    wardId: json['wardId']?.toString(),
    reportedBy: json['reportedBy']?.toString(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    status: _statusFromString(json['status']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'description': description,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'areaName': areaName, 'roadNumber': roadNumber,
    if (wardNumber != null) 'wardNumber': wardNumber,
    if (wardId != null) 'wardId': wardId,
    if (reportedBy != null) 'reportedBy': reportedBy,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };

  static IssueStatus _statusFromString(String v) {
    switch (v) {
      case 'open':
      case 'inProgress': case 'in_progress': return IssueStatus.inProgress;
      case 'resolved': return IssueStatus.resolved;
      default: return IssueStatus.submitted;
    }
  }
}
