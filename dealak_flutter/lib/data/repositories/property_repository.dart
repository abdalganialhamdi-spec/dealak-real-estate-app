import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class PropertyRepository {
  final DioClient _dioClient;

  PropertyRepository(this._dioClient);

  List _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw.containsKey('data')) return raw['data'] as List;
    return [];
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    return raw as Map<String, dynamic>;
  }

  Future<PaginatedResponse<PropertyModel>> getProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.properties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<PropertyModel> getProperty(int id) async {
    final response = await _dioClient.get('${ApiEndpoints.properties}/$id');
    return PropertyModel.fromJson(_extractMap(response.data));
  }

  Future<PropertyModel> getPropertyBySlug(String slug) async {
    final response = await _dioClient.get(ApiEndpoints.propertyBySlug(slug));
    return PropertyModel.fromJson(_extractMap(response.data));
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiEndpoints.properties, data: data);
    final json = response.data;
    return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('${ApiEndpoints.properties}/$id', data: data);
    final json = response.data;
    return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
  }

  Future<void> deleteProperty(int id) async {
    await _dioClient.delete('${ApiEndpoints.properties}/$id');
  }

  Future<List<PropertyModel>> getFeatured() async {
    final response = await _dioClient.get(ApiEndpoints.featuredProperties);
    return _extractList(response.data).map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedResponse<PropertyModel>> getMyProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.myProperties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<List<PropertyModel>> getSimilar(int id) async {
    final response = await _dioClient.get(ApiEndpoints.propertySimilar(id));
    return _extractList(response.data).map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> uploadImages(int propertyId, List<MultipartFile> files) async {
    final formData = FormData.fromMap({'images': files});
    await _dioClient.upload(ApiEndpoints.propertyImages(propertyId), formData);
  }

  Future<void> deleteImage(int propertyId, int imageId) async {
    await _dioClient.delete(ApiEndpoints.propertyImage(propertyId, imageId));
  }
}
