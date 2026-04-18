import '../../../core/services/api_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  final _api = ApiService.instance;
  final _storage = LocalStorageService.instance;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final data = await _api.post('/auth/register', {
      'name': name, 'email': email, 'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    if (user.token != null) await _storage.saveToken(user.token!);
    await _storage.saveUser(user.toJson());
    return user;
  }

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    bool isEmail = true,
  }) async {
    final data = await _api.post('/auth/login', {
      if (isEmail) 'email': emailOrPhone else 'phone': emailOrPhone,
      'password': password,
    });
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    if (user.token != null) await _storage.saveToken(user.token!);
    await _storage.saveUser(user.toJson());
    return user;
  }

  Future<UserModel> loginAuthority({
    required String email,
    required String wardCode,
  }) async {
    final data = await _api.post('/auth/authority-login', {
      'email': email, 'wardCode': wardCode,
    });
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    if (user.token != null) await _storage.saveToken(user.token!);
    await _storage.saveUser(user.toJson());
    return user;
  }

  Future<UserModel> selectWard({
    required String userId,
    required String wardId,
    required String wardName,
  }) async {
    final data = await _api.patch('/auth/ward', {
      'userId': userId, 'wardId': wardId, 'wardName': wardName,
    });
    await _storage.saveWardId(wardId);
    await _storage.saveWardName(wardName);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _storage.clearToken();
    await _storage.clearUser();
  }

  UserModel? getCachedUser() {
    final data = _storage.getUser();
    return data != null ? UserModel.fromJson(data) : null;
  }
}
