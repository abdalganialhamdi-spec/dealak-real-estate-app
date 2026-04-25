import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/notification_model.dart';
import 'package:dealak_flutter/providers/notification_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await ref.read(notificationProvider.notifier).markAllAsRead();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationProvider.notifier).loadNotifications(),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none,
                message: 'لا توجد إشعارات - ستظهر هنا جميع الإشعارات الجديدة',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(notification: notification);
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () =>
                ref.read(notificationProvider.notifier).loadNotifications(),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final createdAt = notification.createdAt != null
        ? Formatters.dateTime(notification.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).cardColor
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? Theme.of(context).dividerColor
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(notification.type.isEmpty ? 'info' : notification.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  createdAt,
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'property':
        return Icons.home;
      case 'deal':
        return Icons.handshake;
      case 'message':
        return Icons.chat;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }
}
