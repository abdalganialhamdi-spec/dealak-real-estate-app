import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class PropertyRepository extends BaseRepository {
  final DioClient _dioClient;

  PropertyRepository(this._dioClient);

  Future<PaginatedResponse<PropertyModel>> getProperties({Map<String, dynamic>? params}) async {
    return safeCall(() async {
      final mergedParams = {
        'include': 'images,owner',
        ...?params,
      };
      final response = await _dioClient.get(ApiEndpoints.properties, queryParameters: mergedParams);
      return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
    });
  }

  Future<PropertyModel> getProperty(int id) async {
    return safeCall(() async {
      final response = await _dioClient.get('${ApiEndpoints.properties}/$id');
      return PropertyModel.fromJson(_extractMap(response.data));
    });
  }

  Future<PropertyModel> getPropertyBySlug(String slug) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.propertyBySlug(slug));
      return PropertyModel.fromJson(_extractMap(response.data));
    });
  }

  Future<PropertyModel> createProperty(Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.properties, data: data);
      final json = response.data;
      return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
    });
  }

  Future<PropertyModel> updateProperty(int id, Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.put('${ApiEndpoints.properties}/$id', data: data);
      final json = response.data;
      return PropertyModel.fromJson(json.containsKey('property') ? json['property'] : _extractMap(json));
    });
  }

  Future<void> deleteProperty(int id) async {
    return safeCall(() async {
      await _dioClient.delete('${ApiEndpoints.properties}/$id');
    });
  }

  Future<List<PropertyModel>> getFeatured() async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.featuredProperties);
      return _extractList(response.data).map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<PaginatedResponse<PropertyModel>> getMyProperties({Map<String, dynamic>? params}) async {
    return safeCall(() async {
      final mergedParams = {
        'include': 'images,owner',
        ...?params,
      };
      final response = await _dioClient.get(ApiEndpoints.myProperties, queryParameters: mergedParams);
      return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
    });
  }

  Future<List<PropertyModel>> getSimilar(int id) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.propertySimilar(id));
      return _extractList(response.data).map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> uploadImages(int propertyId, List<MultipartFile> files) async {
    return safeCall(() async {
      final formData = FormData();
      for (final file in files) {
        formData.files.add(MapEntry('images[]', file));
      }
      await _dioClient.upload(ApiEndpoints.propertyImages(propertyId), formData);
    });
  }

  Future<void> deleteImage(int propertyId, int imageId) async {
    return safeCall(() async {
      await _dioClient.delete(ApiEndpoints.propertyImage(propertyId, imageId));
    });
  }

  Future<PropertyModel> createPropertyWithImages({
    required Map<String, dynamic> data,
    required List<MultipartFile> images,
    void Function(double)? onProgress,
  }) async {
    // 1. Create property as DRAFT
    final propertyData = Map<String, dynamic>.from(data);
    propertyData['status'] = 'DRAFT';
    
    final property = await createProperty(propertyData);

    // 2. Upload images if any
    if (images.isNotEmpty) {
      try {
        await uploadImages(property.id, images);
      } catch (e) {
        // Return the draft property so the user can retry upload
        // The calling code should handle this
        rethrow;
      }
    }

    // 3. Mark as AVAILABLE
    return await updateProperty(property.id, {'status': 'AVAILABLE'});
  }
}
