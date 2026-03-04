import 'package:flutter/material.dart';
import 'package:flutter_app_nagar_watch/core/models/issue_model.dart';

class IssueProvider extends ChangeNotifier {
  final List<IssueModel> _issues = [];

  List<IssueModel> get issues => List.unmodifiable(_issues);

  void addIssue({
    required String title,
    required String description,
    String? imageUrl,
    required String areaName,
    required String roadNumber,
  }) {
    final newIssue = IssueModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: imageUrl,
      areaName: areaName,
      roadNumber: roadNumber,
      createdAt: DateTime.now(),
      status: IssueStatus.submitted,
    );

    _issues.add(newIssue);
    notifyListeners();
  }

  void updateStatus(String id, IssueStatus newStatus) {
    final issue = _issues.firstWhere((issue) => issue.id == id);

    issue.status = newStatus;
    notifyListeners();
  }
}
