import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/request_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class RequestRepository extends BaseRepository {
  final DioClient _dioClient;

  RequestRepository(this._dioClient);

  Future<PaginatedResponse<PropertyRequestModel>> getRequests({
    int page = 1,
  }) async {
    return safeCall(() async {
      final response = await _dioClient.get(
        ApiEndpoints.requests,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data,
        PropertyRequestModel.fromJson,
      );
    });
  }

  Future<PropertyRequestModel> createRequest(Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.requests, data: data);
      return PropertyRequestModel.fromJson(
        response.data['request'] ?? response.data,
      );
    });
  }

  Future<PropertyRequestModel> updateRequest(
    int id,
    Map<String, dynamic> data,
  ) async {
    return safeCall(() async {
      final response = await _dioClient.put(
        '${ApiEndpoints.requests}/$id',
        data: data,
      );
      return PropertyRequestModel.fromJson(
        response.data['request'] ?? response.data,
      );
    });
  }

  Future<void> deleteRequest(int id) async {
    return safeCall(() async {
      await _dioClient.delete('${ApiEndpoints.requests}/$id');
    });
  }

  Future<PaginatedResponse<PropertyRequestModel>> getMyRequests({
    int page = 1,
  }) async {
    return safeCall(() async {
      final response = await _dioClient.get(
        ApiEndpoints.requests,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(
        response.data,
        PropertyRequestModel.fromJson,
      );
    });
  }
}
