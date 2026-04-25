import 'package:dio/dio.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorage _storage;

  ApiInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isAuthRoute(err.requestOptions)) {
      final token = await _storage.getToken();
      if (token != null && !_isRefreshRequest(err.requestOptions)) {
        try {
          final dio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ));
          final response = await dio.post('/auth/refresh');
          final newToken = response.data['token'];
          await _storage.saveToken(newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await Dio().fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await _storage.clearAll();
        }
      } else {
        await _storage.clearAll();
      }
    }
    handler.next(err);
  }

  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('/auth/refresh');
  }

  bool _isAuthRoute(RequestOptions options) {
    return options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');
  }
}
