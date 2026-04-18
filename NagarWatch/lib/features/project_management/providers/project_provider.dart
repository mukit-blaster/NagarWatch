import 'package:flutter/foundation.dart';
import '../../../core/models/project_model.dart';
import '../repository/project_repository.dart';

enum ProjectFilter { all, ongoing, planned, completed }

class ProjectProvider extends ChangeNotifier {
  final _repo = ProjectRepository();

  List<ProjectModel> _projects = [];
  ProjectFilter _filter = ProjectFilter.all;
  String _search = '';
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  List<ProjectModel> get projects => _projects;
  ProjectFilter get filter => _filter;
  String get search => _search;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  List<ProjectModel> get filtered {
    var list = _projects;
    if (_filter != ProjectFilter.all) {
      list = list.where((p) {
        switch (_filter) {
          case ProjectFilter.ongoing: return p.status == ProjectStatus.ongoing;
          case ProjectFilter.planned: return p.status == ProjectStatus.planned;
          case ProjectFilter.completed: return p.status == ProjectStatus.completed;
          case ProjectFilter.all: return true;
        }
      }).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.location.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  /// Load projects with fallback to offline cache
  Future<void> loadProjects({String? wardId}) async {
    _setLoading(true);
    try {
      if (wardId != null) {
        _projects = await _repo.fetchByWard(wardId);
      } else {
        _projects = await _repo.fetchAll();
      }
      if (_projects.isEmpty) _projects = List.from(kSampleProjects);
      _error = null;
      _isOnline = true;
    } catch (e) {
      _error = e.toString();
      _isOnline = false;
      _projects = List.from(kSampleProjects);
    } finally {
      _setLoading(false);
    }
  }

  /// Stream real-time project updates (recommended for live data)
  void streamProjectsByWard(String wardId) {
    _setLoading(true);
    try {
      _repo.streamProjectsByWard(wardId).listen(
        (projects) {
          _projects = projects.isNotEmpty ? projects : List.from(kSampleProjects);
          _error = null;
          _isOnline = true;
          _setLoading(false);
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isOnline = false;
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isOnline = false;
      _setLoading(false);
    }
  }

  /// Stream real-time project updates by status
  void streamProjectsByStatus(String wardId, ProjectStatus status) {
    _setLoading(true);
    try {
      _repo.streamProjectsByStatus(wardId, status).listen(
        (projects) {
          _projects = projects.isNotEmpty ? projects : [];
          _error = null;
          _isOnline = true;
          _setLoading(false);
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isOnline = false;
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isOnline = false;
      _setLoading(false);
    }
  }

  Future<void> createProject(ProjectModel project) async {
    try {
      final created = await _repo.create(project);
      _projects = [created, ..._projects];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProject(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _repo.update(id, updates);
      _projects = _projects.map((p) => p.id == id ? updated : p).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _repo.delete(id);
      _projects = _projects.where((p) => p.id != id).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setFilter(ProjectFilter f) {
    _filter = f;
    notifyListeners();
  }
  void setSearch(String q) { _search = q; notifyListeners(); }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
}
