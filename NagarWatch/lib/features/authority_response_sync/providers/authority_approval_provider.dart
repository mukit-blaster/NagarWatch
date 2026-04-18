import 'package:flutter/foundation.dart';
import '../repository/authority_approval_repository.dart';

class AuthorityApprovalProvider extends ChangeNotifier {
  final _repo = AuthorityApprovalRepository();

  bool _isLoading = false;
  List<Map<String, dynamic>> _pendingRequests = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  String? get error => _error;

  Future<void> fetchPendingRequests() async {
    _setLoading(true);
    try {
      _pendingRequests = await _repo.getPendingRequests();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveRequest(String requestId) async {
    _setLoading(true);
    try {
      await _repo.approveRequest(requestId);
      _pendingRequests.removeWhere((r) => r['id'] == requestId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectRequest(String requestId, String reason) async {
    _setLoading(true);
    try {
      await _repo.rejectRequest(requestId, reason);
      _pendingRequests.removeWhere((r) => r['id'] == requestId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
