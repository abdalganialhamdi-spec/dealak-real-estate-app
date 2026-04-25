import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/review_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class ReviewRepository {
  final DioClient _dioClient;

  ReviewRepository(this._dioClient);

  Future<PaginatedResponse<ReviewModel>> getPropertyReviews(int propertyId, {int page = 1}) async {
    final response = await _dioClient.get(
      ApiEndpoints.propertyReviews(propertyId),
      queryParameters: {'page': page},
    );
    return PaginatedResponse.fromJson(response.data, ReviewModel.fromJson);
  }

  Future<ReviewModel> createReview(Map<String, dynamic> data) async {
    final response = await _dioClient.post(ApiEndpoints.reviews, data: data);
    return ReviewModel.fromJson(response.data['review']);
  }

  Future<ReviewModel> updateReview(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('${ApiEndpoints.reviews}/$id', data: data);
    return ReviewModel.fromJson(response.data['review']);
  }

  Future<void> deleteReview(int id) async {
    await _dioClient.delete('${ApiEndpoints.reviews}/$id');
  }
}