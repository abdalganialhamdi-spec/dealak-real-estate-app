import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/deal_model.dart';
import 'package:dealak_flutter/providers/deal_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class DealsListScreen extends ConsumerWidget {
  const DealsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(dealsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الصفقات')),
      body: dealsAsync.when(
        data: (paginated) {
          final deals = paginated.data;
          if (deals.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.handshake_outlined,
              message: 'لا توجد صفقات بعد',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dealsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deals.length,
              itemBuilder: (context, index) => _DealCard(deal: deals[index]),
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري تحميل الصفقات...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(dealsProvider),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final DealModel deal;
  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.dealDetail}/${deal.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deal.property?.title ?? 'صفقة #${deal.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                _DealStatusChip(status: deal.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(Formatters.currency(deal.amount), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (deal.buyer != null) ...[
                  const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  Text(' ${deal.buyer!.fullName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 16),
                ],
                if (deal.totalPaid > 0) ...[
                  const Icon(Icons.payment, size: 16, color: AppColors.textSecondary),
                  Text(' مدفوع: ${Formatters.currency(deal.totalPaid)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
            if (deal.createdAt != null) ...[
              const SizedBox(height: 6),
              Text(Formatters.date(deal.createdAt!), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DealStatusChip extends StatelessWidget {
  final String status;
  const _DealStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  (Color, String) _getStatusInfo() {
    switch (status) {
      case 'PENDING': return (AppColors.pending, 'قيد الانتظار');
      case 'ACTIVE': return (AppColors.info, 'نشطة');
      case 'COMPLETED': return (AppColors.success, 'مكتملة');
      case 'CANCELLED': return (AppColors.error, 'ملغاة');
      default: return (AppColors.textSecondary, status);
    }
  }
}
