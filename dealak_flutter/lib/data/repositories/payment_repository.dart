import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/payment_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class PaymentRepository extends BaseRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<List<PaymentModel>> getPayments(int dealId) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.dealPayments(dealId));
      return _extractList(response.data).map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<PaymentModel> recordPayment(int dealId, Map<String, dynamic> data) async {
    return safeCall(() async {
      final response = await _dioClient.post(ApiEndpoints.dealPayments(dealId), data: data);
      return PaymentModel.fromJson(_extractMap(response.data));
    });
  }
}
