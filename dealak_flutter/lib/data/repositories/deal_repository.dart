import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/deal_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class DealRepository extends BaseRepository {
  final DioClient _dioClient;

  DealRepository(this._dioClient);

  Future<PaginatedResponse<DealModel>> getDeals({int page = 1}) async {
    return safeCall(() async {
      final response = await _dioClient.get(
        ApiEndpoints.deals,
        queryParameters: {'page': page},
      );
      return PaginatedResponse.fromJson(response.data, DealModel.fromJson);
    });
  }

  Future<DealModel> getDeal(int id) async {
    return safeCall(() async {
      final response = await _dioClient.get('${ApiEndpoints.deals}/$id');
      return DealModel.fromJson(_extractMap(response.data));
    });
  }

  Future<DealModel> createDeal(Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.deals, data: data);
      final json = response.data;
      return DealModel.fromJson(json['deal'] ?? _extractMap(json));
    });
  }

  Future<DealModel> updateDeal(int id, Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.put(
        '${ApiEndpoints.deals}/$id',
        data: data,
      );
      final json = response.data;
      return DealModel.fromJson(json['deal'] ?? _extractMap(json));
    });
  }

  Future<void> recordPayment(int dealId, Map<String, dynamic> data) async {
    return safeCall(() async {
      await _dioClient.post(ApiEndpoints.dealPayments(dealId), data: data);
    });
  }

  Future<List<dynamic>> getPayments(int dealId) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.dealPayments(dealId));
      return _extractList(response.data);
    });
  }
}
