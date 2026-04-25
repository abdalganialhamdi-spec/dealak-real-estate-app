import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/favorite_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/base_repository.dart';

class FavoriteRepository extends BaseRepository {
  final DioClient _dioClient;

  FavoriteRepository(this._dioClient);

  Future<PaginatedResponse<FavoriteModel>> getFavorites({int page = 1}) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.favorites, queryParameters: {'page': page});
      return PaginatedResponse.fromJson(response.data, FavoriteModel.fromJson);
    });
  }

  Future<void> addFavorite(int propertyId) async {
    return safeCall(() async {
      await _dioClient.post(ApiEndpoints.favorites, data: {'property_id': propertyId});
    });
  }

  Future<void> removeFavorite(int propertyId) async {
    return safeCall(() async {
      await _dioClient.delete('${ApiEndpoints.favorites}/$propertyId');
    });
  }

  Future<bool> isFavorite(int propertyId) async {
    return safeCall(() async {
      final response = await _dioClient.get(ApiEndpoints.favoriteCheck(propertyId));
      return response.data['is_favorite'] ?? false;
    });
  }
}
