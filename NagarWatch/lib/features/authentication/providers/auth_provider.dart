import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/ward_model.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/location_service.dart';
import '../repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _authorizationStatus; // 'approved', 'pending_approval', null

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authorizationStatus => _authorizationStatus;
  bool get isLoggedIn => _user != null;
  bool get isAuthority => _user?.role == 'authority' || _user?.role == 'admin';
  bool get needsWardSelection => _user != null && (_user!.wardId == null || _user!.wardId!.isEmpty);

  AuthProvider() {
    _user = _repo.getCachedUser();
  }

  Future<bool> register({required String name, required String email, required String password, String? phone}) async {
    _setLoading(true);
    try {
      _user = await _repo.register(name: name, email: email, password: password, phone: phone);
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

  Future<bool> login({required String emailOrPhone, required String password, bool isEmail = true}) async {
    _setLoading(true);
    try {
      _user = await _repo.login(emailOrPhone: emailOrPhone, password: password, isEmail: isEmail);
      _authorizationStatus = _user?.approvalStatus;
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

  Future<bool> loginAuthority({required String email, required String wardCode}) async {
    _setLoading(true);
    try {
      _user = await _repo.loginAuthority(email: email, wardCode: wardCode);
      _authorizationStatus = _user?.approvalStatus;
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

  Future<bool> selectWard(String wardId, String wardName) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      return await _saveWardSelection(wardId, wardName);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> autoDetectWardAndSelect() async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        _error = 'Could not detect location. You can use Detect Area from dashboard.';
        notifyListeners();
        return false;
      }

      var nearestWard = WardModel.sampleWards.first;
      var nearestDistanceKm = double.infinity;

      for (final ward in WardModel.sampleWards) {
        final distanceKm = LocationService.distanceKm(
          position.latitude,
          position.longitude,
          ward.centerLat,
          ward.centerLng,
        );
        if (distanceKm < nearestDistanceKm) {
          nearestDistanceKm = distanceKm;
          nearestWard = ward;
        }
      }

      return await _saveWardSelection(nearestWard.id, nearestWard.name);
    } catch (e) {
      _error = 'Could not detect location. You can use Detect Area from dashboard.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }

  Future<bool> _saveWardSelection(String wardId, String wardName) async {
    if (_user == null) return false;
    try {
      _user = await _repo.selectWard(userId: _user!.id, wardId: wardId, wardName: wardName);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Even if API fails, save locally to keep user flow uninterrupted.
      _user = _user!.copyWith(wardId: wardId, wardName: wardName);
      await LocalStorageService.instance.saveWardId(wardId);
      await LocalStorageService.instance.saveWardName(wardName);
      _error = null;
      notifyListeners();
      return true;
    }
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
}
