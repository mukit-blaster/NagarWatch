enum IssueStatus { submitted, inProgress, resolved }

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String areaName;
  final String roadNumber;
  final String? wardNumber;
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
    required this.createdAt,
    this.status = IssueStatus.submitted,
  });
}
