enum ProjectStatus { planned, ongoing, completed, delayed }
enum ProjectType { road, drainage, lighting, waste, park, building, other }
enum MilestoneState { completed, current, pending }

class MilestoneModel {
  final String id;
  final String title;
  final String targetDate;
  final MilestoneState state;

  const MilestoneModel({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.state,
  });

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'targetDate': targetDate, 'state': state.name};

  factory MilestoneModel.fromMap(Map<String, dynamic> map) => MilestoneModel(
    id: map['id']?.toString() ?? '',
    title: map['title']?.toString() ?? '',
    targetDate: map['targetDate']?.toString() ?? '',
    state: MilestoneState.values.firstWhere((e) => e.name == map['state'], orElse: () => MilestoneState.pending),
  );
}

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String wardId;
  final String wardName;
  final String location;
  final double latitude;
  final double longitude;
  final double geofenceRadius;
  final double budgetLakh;
  final String deadlineLabel;
  final ProjectStatus status;
  final ProjectType type;
  final int progressPercent;
  final String contractorName;
  final String startDate;
  final String deadlineDate;
  final String priority;
  final List<MilestoneModel> milestones;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.wardId,
    required this.wardName,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.geofenceRadius = 500,
    required this.budgetLakh,
    required this.deadlineLabel,
    required this.status,
    required this.type,
    required this.progressPercent,
    required this.contractorName,
    required this.startDate,
    required this.deadlineDate,
    required this.priority,
    this.milestones = const [],
  });

  Map<String, dynamic> toMap() => {
    'name': name, 'description': description,
    'wardId': wardId, 'wardName': wardName,
    'location': location, 'latitude': latitude, 'longitude': longitude,
    'geofenceRadius': geofenceRadius, 'budgetLakh': budgetLakh,
    'deadlineLabel': deadlineLabel, 'status': status.name,
    'type': type.name, 'progressPercent': progressPercent,
    'contractorName': contractorName, 'startDate': startDate,
    'deadlineDate': deadlineDate, 'priority': priority,
    'milestones': milestones.map((m) => m.toMap()).toList(),
  };

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    description: map['description']?.toString() ?? '',
    wardId: map['wardId']?.toString() ?? '',
    wardName: map['wardName']?.toString() ?? '',
    location: map['location']?.toString() ?? '',
    latitude: (map['latitude'] as num?)?.toDouble() ?? 23.8103,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4125,
    geofenceRadius: (map['geofenceRadius'] as num?)?.toDouble() ?? 500,
    budgetLakh: (map['budgetLakh'] as num?)?.toDouble() ?? 0,
    deadlineLabel: map['deadlineLabel']?.toString() ?? '',
    status: ProjectStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => ProjectStatus.planned),
    type: ProjectType.values.firstWhere((e) => e.name == map['type'], orElse: () => ProjectType.other),
    progressPercent: (map['progressPercent'] as num?)?.toInt() ?? 0,
    contractorName: map['contractorName']?.toString() ?? '',
    startDate: map['startDate']?.toString() ?? '',
    deadlineDate: map['deadlineDate']?.toString() ?? '',
    priority: map['priority']?.toString() ?? 'Medium',
    milestones: (map['milestones'] as List<dynamic>?)
        ?.map((m) => MilestoneModel.fromMap(m as Map<String, dynamic>))
        .toList() ?? [],
  );

  ProjectModel copyWith({
    String? id, String? name, String? description, String? wardId, String? wardName,
    String? location, double? latitude, double? longitude, double? geofenceRadius,
    double? budgetLakh, String? deadlineLabel, ProjectStatus? status, ProjectType? type,
    int? progressPercent, String? contractorName, String? startDate, String? deadlineDate,
    String? priority, List<MilestoneModel>? milestones,
  }) => ProjectModel(
    id: id ?? this.id, name: name ?? this.name, description: description ?? this.description,
    wardId: wardId ?? this.wardId, wardName: wardName ?? this.wardName,
    location: location ?? this.location, latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude, geofenceRadius: geofenceRadius ?? this.geofenceRadius,
    budgetLakh: budgetLakh ?? this.budgetLakh, deadlineLabel: deadlineLabel ?? this.deadlineLabel,
    status: status ?? this.status, type: type ?? this.type,
    progressPercent: progressPercent ?? this.progressPercent,
    contractorName: contractorName ?? this.contractorName,
    startDate: startDate ?? this.startDate, deadlineDate: deadlineDate ?? this.deadlineDate,
    priority: priority ?? this.priority, milestones: milestones ?? this.milestones,
  );
}

// Sample data for offline fallback
const List<ProjectModel> kSampleProjects = [
  ProjectModel(
    id: 'p1', name: 'Road Widening – NH 30', wardId: 'ward_12', wardName: 'Ward 12 – Gulshan',
    description: 'Widening of NH-30 from 2-lane to 4-lane to ease traffic congestion.',
    location: 'NH-30, Gulshan, Dhaka', latitude: 23.7806, longitude: 90.4141,
    geofenceRadius: 600, budgetLakh: 320, deadlineLabel: "Dec '25",
    status: ProjectStatus.ongoing, type: ProjectType.road, progressPercent: 65,
    contractorName: 'Delta Construction Ltd', startDate: '2025-03-01', deadlineDate: '2025-12-31',
    priority: 'High',
    milestones: [
      MilestoneModel(id: 'm1', title: 'Site Survey', targetDate: "Mar '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm2', title: 'Excavation', targetDate: "Jun '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm3', title: 'Paving', targetDate: "Sep '25", state: MilestoneState.current),
      MilestoneModel(id: 'm4', title: 'Finishing', targetDate: "Dec '25", state: MilestoneState.pending),
    ],
  ),
  ProjectModel(
    id: 'p2', name: 'Drainage System – Ward 12', wardId: 'ward_12', wardName: 'Ward 12 – Gulshan',
    description: 'Installing underground drainage system to prevent waterlogging during monsoons.',
    location: 'Gulshan-2, Dhaka', latitude: 23.7837, longitude: 90.4200,
    geofenceRadius: 400, budgetLakh: 85, deadlineLabel: "Feb '26",
    status: ProjectStatus.planned, type: ProjectType.drainage, progressPercent: 10,
    contractorName: 'AquaFlow Engineers', startDate: '2025-10-01', deadlineDate: '2026-02-28',
    priority: 'Medium',
    milestones: [
      MilestoneModel(id: 'm5', title: 'Planning', targetDate: "Oct '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm6', title: 'Procurement', targetDate: "Dec '25", state: MilestoneState.current),
      MilestoneModel(id: 'm7', title: 'Installation', targetDate: "Feb '26", state: MilestoneState.pending),
    ],
  ),
  ProjectModel(
    id: 'p3', name: 'LED Street Lights – Zone A', wardId: 'ward_12', wardName: 'Ward 12 – Gulshan',
    description: 'Replacing old sodium lamps with energy-efficient LED street lights.',
    location: 'Gulshan Avenue, Dhaka', latitude: 23.7780, longitude: 90.4120,
    geofenceRadius: 300, budgetLakh: 42, deadlineLabel: "Oct '25",
    status: ProjectStatus.completed, type: ProjectType.lighting, progressPercent: 100,
    contractorName: 'BrightPath Solutions', startDate: '2025-06-01', deadlineDate: '2025-10-31',
    priority: 'Low',
    milestones: [
      MilestoneModel(id: 'm8', title: 'Installation', targetDate: "Aug '25", state: MilestoneState.completed),
      MilestoneModel(id: 'm9', title: 'Testing', targetDate: "Oct '25", state: MilestoneState.completed),
    ],
  ),
];
