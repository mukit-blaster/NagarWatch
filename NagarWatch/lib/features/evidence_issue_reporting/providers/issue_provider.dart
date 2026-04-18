import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/issue_model.dart';
import '../../../core/services/notification_service.dart';
import '../repository/issue_repository.dart';

class IssueProvider extends ChangeNotifier {
  final _repo = IssueRepository();

  List<IssueModel> _issues = [];
  final List<IssueModel> _offlineIssues = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  bool _isOnline = true;

  List<IssueModel> get issues => [..._offlineIssues, ..._issues];
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get errorMessage => _error;
  bool get isOnline => _isOnline;
  int get pendingOfflineCount => _repo.getPendingOfflineCount();
  bool get hasPendingOfflineSubmissions => _repo.hasPendingOfflineSubmissions();

  /// Get real-time issues stream by ward
  /// Recommended for use with StreamBuilder for live data updates
  Stream<List<IssueModel>> getIssuesStream(String wardId) {
    return _repo.streamIssuesByWard(wardId);
  }

  /// Get real-time issues stream without ward filter.
  Stream<List<IssueModel>> getAllIssuesStream() {
    return _repo.streamAllIssues();
  }

  /// Get real-time issues stream filtered by status
  Stream<List<IssueModel>> getIssuesStreamByStatus(
    String wardId,
    IssueStatus status,
  ) {
    return _repo.streamIssuesByStatus(wardId, status);
  }

  /// Load issues with offline fallback (one-time fetch)
  Future<void> loadIssues({String? wardId}) async {
    _setLoading(true);
    try {
      _issues = await _repo.fetchAll(wardId: wardId);
      _error = null;
      _isOnline = true;
    } catch (e) {
      _error = e.toString();
      _isOnline = false;
      _issues = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Stream real-time issue updates by ward (recommended for live data)
  void streamIssuesByWard(String wardId) {
    _setLoading(true);
    try {
      _repo.streamIssuesByWard(wardId).listen(
        (issues) {
          _issues = issues;
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

  /// Stream real-time issue updates by status
  void streamIssuesByStatus(String wardId, IssueStatus status) {
    _setLoading(true);
    try {
      _repo.streamIssuesByStatus(wardId, status).listen(
        (issues) {
          _issues = issues;
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

  /// Add issue with automatic offline queuing
  Future<bool> addIssue({
    required String title,
    required String description,
    required String areaName,
    required String roadNumber,
    String? wardId,
    String? wardNumber,
    String? reportedBy,
    double? latitude,
    double? longitude,
    XFile? imageFile,
    bool isOnline = true,
  }) async {
    try {
      final issue = await _repo.create(
        title: title,
        description: description,
        areaName: areaName,
        roadNumber: roadNumber,
        wardId: wardId,
        wardNumber: wardNumber,
        reportedBy: reportedBy,
        latitude: latitude,
        longitude: longitude,
        imageFile: imageFile,
      );

      // Check if this is an offline issue
      if (issue.id.toString().startsWith('offline_')) {
        _offlineIssues.insert(0, issue);
      } else {
        _issues.insert(0, issue);
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update issue status
  Future<void> updateStatus(String id, IssueStatus newStatus) async {
    try {
      await _repo.updateStatus(id, newStatus);

      // Update in local list
      final idx = _issues.indexWhere((i) => i.id == id);
      if (idx >= 0) {
        _issues[idx].status = newStatus;
        notifyListeners();
        await NotificationService.instance
            .notifyIssueStatusChanged(_issues[idx].title, newStatus.name);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Sync offline queue with Firestore
  Future<void> syncOfflineQueue() async {
    if (!_isOnline || !hasPendingOfflineSubmissions) {
      return;
    }

    _setSyncing(true);
    try {
      await _repo.syncOfflineQueue();

      // Move synced issues from offline to online list
      _offlineIssues.clear();

      // Reload issues to get fresh data
      _issues.clear();

      _error = null;
      notifyListeners();
      print('✓ Offline queue synced successfully');
    } catch (e) {
      _error = 'Sync failed: $e';
      notifyListeners();
      print('✗ Sync failed: $e');
    } finally {
      _setSyncing(false);
    }
  }

  /// Clear offline queue (use with caution - data will be lost)
  Future<void> clearOfflineQueue() async {
    await _repo.clearOfflineQueue();
    _offlineIssues.clear();
    notifyListeners();
  }

  /// Update online status (called by connectivity service)
  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();

    // Auto-sync when connection is restored
    if (online && hasPendingOfflineSubmissions) {
      syncOfflineQueue();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSyncing(bool v) {
    _isSyncing = v;
    notifyListeners();
  }
}
