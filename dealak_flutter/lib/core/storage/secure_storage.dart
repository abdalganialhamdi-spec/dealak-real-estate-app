import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUserId(int id) async {
    await _storage.write(key: _userIdKey, value: id.toString());
  }

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> hasToken() async {
    return await getToken() != null;
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }
}
