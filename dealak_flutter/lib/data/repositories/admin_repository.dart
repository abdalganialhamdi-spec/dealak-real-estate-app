import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/models/deal_model.dart';

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dioClient.get(ApiEndpoints.adminDashboard);
    return response.data;
  }

  Future<PaginatedResponse<PropertyModel>> getAllProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.adminProperties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiEndpoints.adminProperties, data: data);
    final json = response.data;
    return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiEndpoints.adminProperty(id), data: data);
    final json = response.data;
    return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
  }

  Future<void> deleteProperty(int id) async {
    await _dioClient.delete(ApiEndpoints.adminProperty(id));
  }

  Future<List> uploadImages(int propertyId, List<MultipartFile> files) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(MapEntry('images[]', file));
    }
    final response = await _dioClient.upload(ApiEndpoints.adminPropertyImages(propertyId), formData);
    final data = response.data;
    if (data is Map && data.containsKey('images')) {
      return data['images'] as List;
    }
    return [];
  }

  Future<void> deleteImage(int propertyId, int imageId) async {
    await _dioClient.delete(ApiEndpoints.adminPropertyImage(propertyId, imageId));
  }

  Future<void> toggleFeatured(int id) async {
    await _dioClient.put(ApiEndpoints.adminToggleFeatured(id));
  }

  Future<PaginatedResponse<PropertyModel>> getPendingProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.adminPendingProperties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<void> approveProperty(int id) async {
    await _dioClient.put(ApiEndpoints.adminApproveProperty(id));
  }

  Future<PaginatedResponse<UserModel>> getUsers({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.adminUsers, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, UserModel.fromJson);
  }

  Future<void> updateUserStatus(int id, bool isActive) async {
    await _dioClient.put(ApiEndpoints.adminUserStatus(id), data: {'is_active': isActive});
  }

  Future<void> updateUserRole(int id, String role) async {
    await _dioClient.put('${ApiEndpoints.adminUsers}/$id/role', data: {'role': role});
  }

  Future<List<DealModel>> getUserDeals(int id) async {
    final response = await _dioClient.get('${ApiEndpoints.adminUsers}/$id/deals');
    return (response.data as List).map((e) => DealModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getReports() async {
    final response = await _dioClient.get(ApiEndpoints.adminReports);
    return response.data;
  }
}
