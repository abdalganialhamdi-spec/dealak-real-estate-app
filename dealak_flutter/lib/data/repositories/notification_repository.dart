import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/notification_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  Future<PaginatedResponse<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _dioClient.get(ApiEndpoints.notifications, queryParameters: {'page': page});
    return PaginatedResponse.fromJson(response.data, NotificationModel.fromJson);
  }

  Future<void> markAsRead(String id) async {
    await _dioClient.put(ApiEndpoints.notificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dioClient.put(ApiEndpoints.readAll);
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.get(ApiEndpoints.unreadCount);
    return response.data['unread_count'] ?? 0;
  }

  Future<void> registerDeviceToken(String token, {String? platform}) async {
    await _dioClient.post(ApiEndpoints.deviceToken, data: {
      'device_token': token,
      'platform': platform,
    });
  }
}
