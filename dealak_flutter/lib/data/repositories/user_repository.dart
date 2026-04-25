import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/user_model.dart';

class UserRepository {
  final DioClient _dioClient;

  UserRepository(this._dioClient);

  Future<UserModel> getProfile() async {
    final response = await _dioClient.get(ApiEndpoints.userProfile);
    final json = response.data;
    return UserModel.fromJson(json['data'] ?? json['user'] ?? json);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiEndpoints.userProfile, data: data);
    return UserModel.fromJson(response.data['user'] ?? response.data);
  }

  Future<UserModel> show(int id) async {
    final response = await _dioClient.get(ApiEndpoints.userById(id));
    final json = response.data;
    return UserModel.fromJson(json['data'] ?? json);
  }

  Future<void> updatePassword(Map<String, dynamic> data) async {
    await _dioClient.put(ApiEndpoints.userPassword, data: data);
  }

  Future<UserModel> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await _dioClient.upload(ApiEndpoints.userAvatar, formData);
    return UserModel.fromJson(response.data['user'] ?? response.data);
  }
}
