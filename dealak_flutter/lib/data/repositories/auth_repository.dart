import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class AuthRepository extends BaseRepository {
  final DioClient _dioClient;
  final SecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final json = response.data;
      final data = json['data'];
      await _storage.saveToken(data['token']);
      final userJson = _extractMap(data['user']);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return {
        'user': user,
        'token': data['token'],
      };
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.register, data: userData);
      final json = response.data;
      final data = json['data'];
      await _storage.saveToken(data['token']);
      final userJson = _extractMap(data['user']);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return {
        'user': user,
        'token': data['token'],
      };
    });
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } finally {
      await _storage.clearAll();
    }
  }

  Future<UserModel> getMe() async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.me);
      final userJson = _extractMap(response.data);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return user;
    });
  }

  Future<void> forgotPassword(String email) async {
    return safeCall(() async {
      await _dioClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
    });
  }

  Future<void> resetPassword(Map<String, dynamic> data) async {
    return safeCall(() async {
      await _dioClient.post(ApiEndpoints.resetPassword, data: data);
    });
  }
}
