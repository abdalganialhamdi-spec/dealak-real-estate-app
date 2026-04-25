import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/providers/message_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المحادثات')),
      body: conversationsAsync.when(
        data: (paginated) {
          final conversations = paginated.data;
          if (conversations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              message: 'لا توجد محادثات بعد',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(conversationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final otherUser = conv.participantTwo;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      otherUser?.firstName.substring(0, 1) ?? '?',
                      style: const TextStyle(color: AppColors.primary, fontSize: 20),
                    ),
                  ),
                  title: Text(
                    otherUser?.fullName ?? 'مستخدم',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (conv.property != null)
                        Text('بخصوص: ${conv.property!.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      if (conv.lastMessage != null)
                        Text(conv.lastMessage!.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (conv.lastMessageAt != null)
                        Text(
                          _formatTime(conv.lastMessageAt!),
                          style: TextStyle(fontSize: 11, color: conv.lastMessage != null && !conv.lastMessage!.isRead ? AppColors.primary : AppColors.textSecondary),
                        ),
                    ],
                  ),
                  onTap: () => context.push('${RouteNames.chat}/${conv.id}'),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري تحميل المحادثات...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return '${diff.inDays} أيام';
    return '${dt.day}/${dt.month}';
  }
}
