import '../../../core/services/api_service.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/models/project_model.dart';

class AuthorityRepository {
  final _api = ApiService.instance;

  Future<List<IssueModel>> fetchIssues({String? wardId}) async {
    final data = await _api.get('/issues${wardId != null ? '?wardId=$wardId' : ''}');
    return (data as List).map((e) => IssueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProjectModel>> fetchProjects({String? wardId}) async {
    final data = await _api.get('/projects${wardId != null ? '?wardId=$wardId' : ''}');
    return (data as List).map((e) => ProjectModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateIssueStatus(String id, String status) async {
    await _api.patch('/issues/$id/status', {'status': status});
  }

  Future<void> updateEvidenceStatus(String id, String status, {String? reason}) async {
    await _api.patch('/evidence/$id/status', {'status': status, if (reason != null) 'reason': reason});
  }
}
