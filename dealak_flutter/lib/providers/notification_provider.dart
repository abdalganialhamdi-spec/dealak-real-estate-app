import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/notification_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/notification_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.read(dioClientProvider)),
);

final notificationsProvider =
    FutureProvider<PaginatedResponse<NotificationModel>>((ref) async {
      final repo = ref.read(notificationRepositoryProvider);
      return repo.getNotifications();
    });

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;

  NotificationListNotifier(this._repository)
    : super(const AsyncValue.loading());

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getNotifications();
      return result.data;
    });
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }
}

final notificationProvider =
    StateNotifierProvider<
      NotificationListNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      return NotificationListNotifier(ref.read(notificationRepositoryProvider));
    });
