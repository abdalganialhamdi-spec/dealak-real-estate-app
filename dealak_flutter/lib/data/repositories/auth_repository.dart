import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/network/api_exceptions.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorage _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final data = response.data;
      await _storage.saveToken(data['token']);
      final userJson = _unwrapUser(data['user']);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return {
        'user': user,
        'token': data['token'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.register, data: userData);
      final data = response.data;
      await _storage.saveToken(data['token']);
      final userJson = _unwrapUser(data['user']);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return {
        'user': user,
        'token': data['token'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } finally {
      await _storage.clearAll();
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.me);
      final userJson = _unwrapUser(response.data);
      final user = UserModel.fromJson(userJson);
      if (user.role.isNotEmpty) {
        await _storage.saveUserRole(user.role);
      }
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(Map<String, dynamic> data) async {
    try {
      await _dioClient.post(ApiEndpoints.resetPassword, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unwrap {"data": {...}} wrapper from JsonResource responses
  Map<String, dynamic> _unwrapUser(dynamic raw) {
    if (raw is Map && raw.containsKey('data') && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data']);
    }
    return Map<String, dynamic>.from(raw);
  }

  ApiException _handleError(DioException e) {
    final data = e.response?.data;
    final serverMessage = (data is Map) ? (data['message'] ?? data['error']) : null;

    switch (e.response?.statusCode) {
      case 401:
        return ApiException(
          message: serverMessage?.toString() ?? 'بيانات الدخول غير صحيحة',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          message: serverMessage?.toString() ?? 'غير مصرح بهذا الإجراء',
          statusCode: 403,
        );
      case 404: return NotFoundException();
      case 422: return ValidationException(data?['errors'] ?? {});
      default:
        return ApiException(
          message: serverMessage?.toString() ?? 'خطأ في الخادم',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
