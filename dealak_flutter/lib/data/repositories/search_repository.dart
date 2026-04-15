import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/search_filter_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class SearchRepository {
  final DioClient _dioClient;

  SearchRepository(this._dioClient);

  Future<PaginatedResponse<PropertyModel>> search(SearchFilterModel filter) async {
    final response = await _dioClient.get(ApiEndpoints.search, queryParameters: filter.toQueryParams());
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<PaginatedResponse<PropertyModel>> searchNearby(double lat, double lng, {double radius = 5}) async {
    final response = await _dioClient.get(ApiEndpoints.searchNearby, queryParameters: {
      'lat': lat, 'lng': lng, 'radius': radius,
    });
    return PaginatedResponse.fromJson(response.data, PropertyModel.fromJson);
  }

  Future<List<dynamic>> getSuggestions(String query) async {
    final response = await _dioClient.get(ApiEndpoints.searchSuggestions, queryParameters: {'q': query});
    return response.data;
  }

  Future<List<dynamic>> getSavedSearches() async {
    final response = await _dioClient.get(ApiEndpoints.savedSearches);
    return response.data;
  }

  Future<void> saveSearch(String name, Map<String, dynamic> filters) async {
    await _dioClient.post(ApiEndpoints.savedSearches, data: {'name': name, 'filters': filters});
  }
}
