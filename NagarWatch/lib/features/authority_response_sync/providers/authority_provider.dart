import 'package:flutter/foundation.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/notification_service.dart';

class AuthorityProvider extends ChangeNotifier {
  final _api = ApiService.instance;

  List<IssueModel> _issues = [];
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<IssueModel> get issues => _issues;
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      final issueData = await _api.get('/issues');
      _issues = (issueData as List).map((e) => IssueModel.fromJson(e as Map<String, dynamic>)).toList();
      final projData = await _api.get('/projects');
      _projects = (projData as List).map((e) => ProjectModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {}
    finally { _setLoading(false); }
  }

  Future<void> updateIssueStatus(String id, IssueStatus status) async {
    try {
      await _api.patch('/issues/$id/status', {'status': status.name});
      final idx = _issues.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        final old = _issues[idx].status;
        _issues[idx].status = status;
        notifyListeners();
        if (old != status) {
          await NotificationService.instance.notifyIssueStatusChanged(_issues[idx].title, status.name);
        }
      }
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
}
