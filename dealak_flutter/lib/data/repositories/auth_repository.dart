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
      return {
        'user': UserModel.fromJson(data['user']),
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
      return {
        'user': UserModel.fromJson(data['user']),
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
      return UserModel.fromJson(response.data);
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

  ApiException _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401: return UnauthorizedException();
      case 403: return ForbiddenException();
      case 404: return NotFoundException();
      case 422: return ValidationException(e.response?.data['errors'] ?? {});
      default: return ServerException();
    }
  }
}
