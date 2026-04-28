import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class UserRepository extends BaseRepository {
  final DioClient _dioClient;

  UserRepository(this._dioClient);

  Future<UserModel> getProfile() async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.userProfile);
      final json = response.data;
      return UserModel.fromJson(json['user'] ?? _extractMap(json));
    });
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.put(ApiEndpoints.userProfile, data: data);
      final json = response.data;
      return UserModel.fromJson(json['user'] ?? _extractMap(json));
    });
  }

  Future<UserModel> show(int id) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.userById(id));
      return UserModel.fromJson(_extractMap(response.data));
    });
  }

  Future<void> updatePassword(Map<String, dynamic> data) async {
    return safeCall(() async {
      await _dioClient.put(ApiEndpoints.userPassword, data: data);
    });
  }

  Future<UserModel> updateAvatar(String filePath) async {
    return safeCall(() async {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response = await _dioClient.upload(ApiEndpoints.userAvatar, formData);
      final json = response.data;
      return UserModel.fromJson(json['user'] ?? _extractMap(json));
    });
  }
}
