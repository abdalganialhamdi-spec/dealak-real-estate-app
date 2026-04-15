import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class PropertyRepository {
  final DioClient _dioClient;

  PropertyRepository(this._dioClient);

  Future<PaginatedResponse<PropertyModel>> getProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.properties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<PropertyModel> getProperty(int id) async {
    final response = await _dioClient.get('${ApiEndpoints.properties}/$id');
    return PropertyModel.fromJson(response.data);
  }

  Future<PropertyModel> getPropertyBySlug(String slug) async {
    final response = await _dioClient.get(ApiEndpoints.propertyBySlug(slug));
    return PropertyModel.fromJson(response.data);
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiEndpoints.properties, data: data);
    return PropertyModel.fromJson(response.data['property']);
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('${ApiEndpoints.properties}/$id', data: data);
    return PropertyModel.fromJson(response.data['property']);
  }

  Future<void> deleteProperty(int id) async {
    await _dioClient.delete('${ApiEndpoints.properties}/$id');
  }

  Future<List<PropertyModel>> getFeatured() async {
    final response = await _dioClient.get(ApiEndpoints.featuredProperties);
    return (response.data as List).map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<PaginatedResponse<PropertyModel>> getMyProperties({Map<String, dynamic>? params}) async {
    final response = await _dioClient.get(ApiEndpoints.myProperties, queryParameters: params);
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<List<PropertyModel>> getSimilar(int id) async {
    final response = await _dioClient.get(ApiEndpoints.propertySimilar(id));
    return (response.data as List).map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<void> uploadImages(int propertyId, List<MultipartFile> files) async {
    final formData = FormData.fromMap({'images': files});
    await _dioClient.upload(ApiEndpoints.propertyImages(propertyId), formData);
  }

  Future<void> deleteImage(int propertyId, int imageId) async {
    await _dioClient.delete(ApiEndpoints.propertyImage(propertyId, imageId));
  }
}
