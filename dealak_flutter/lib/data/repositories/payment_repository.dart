import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/payment_model.dart';

class PaymentRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<List<PaymentModel>> getPayments(int dealId) async {
    final response = await _dioClient.get(ApiEndpoints.dealPayments(dealId));
    return (response.data as List).map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<PaymentModel> recordPayment(int dealId, Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiEndpoints.dealPayments(dealId), data: data);
    return PaymentModel.fromJson(response.data);
  }
}