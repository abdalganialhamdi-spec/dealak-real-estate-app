import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/request_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class RequestsListScreen extends ConsumerWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي العقارية'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(requestsProvider.notifier).loadRequests(),
        child: requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.search_off,
                title: 'لا توجد طلبات',
                message: 'ابدأ بإضافة طلب عقاري جديد',
                actionLabel: 'إنشاء طلب',
                onAction: () => context.push(RouteNames.createRequest),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _RequestCard(request: request);
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.read(requestsProvider.notifier).loadRequests(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.createRequest),
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final dynamic request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final status = request['status'] ?? 'PENDING';
    final createdAt = request['created_at'] != null
        ? Formatters.dateTime(request['created_at'])
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request['title'] ?? 'طلب عقاري',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          if (request['description'] != null && request['description'].toString().isNotEmpty)
            Text(
              request['description'],
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (request['property_type'] != null) ...[
                Icon(Icons.home_work, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  request['property_type'],
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
              ],
              if (request['city'] != null) ...[
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  request['city'],
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
              const Spacer(),
              Text(
                createdAt,
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'ACTIVE':
        color = AppColors.success;
        label = 'نشط';
        break;
      case 'COMPLETED':
        color = AppColors.primary;
        label = 'مكتمل';
        break;
      case 'CANCELLED':
        color = AppColors.error;
        label = 'ملغي';
        break;
      default:
        color = AppColors.warning;
        label = 'قيد الانتظار';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
