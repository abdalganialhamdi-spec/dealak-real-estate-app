import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/network/api_exceptions.dart';

abstract class BaseRepository {
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

  ApiException _handleError(DioException e) {
    final data = e.response?.data;
    final serverMessage = (data is Map) ? (data['message'] ?? data['error']) : null;

    switch (e.response?.statusCode) {
      case 401:
        return UnauthorizedException();
      case 403:
        return ForbiddenException();
      case 404:
        return NotFoundException();
      case 422:
        return ValidationException(data?['errors'] ?? {});
      case 500:
        return ServerException();
      default:
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          return NetworkException();
        }
        return ApiException(
          message: serverMessage?.toString() ?? 'حدث خطأ غير متوقع',
          statusCode: e.response?.statusCode,
        );
    }
  }

  /// Helper to wrap async calls with error handling
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
