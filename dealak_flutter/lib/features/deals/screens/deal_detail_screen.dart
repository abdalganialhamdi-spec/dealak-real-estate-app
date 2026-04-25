import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/deal_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart' as err;
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class DealDetailScreen extends ConsumerWidget {
  final int dealId;
  const DealDetailScreen({super.key, required this.dealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealAsync = ref.watch(dealDetailProvider(dealId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الصفقة')),
      body: dealAsync.when(
        data: (deal) => _buildContent(context, ref, deal),
        loading: () => const LoadingWidget(),
        error: (e, _) => err.AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(dealDetailProvider(dealId)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic deal) {
    final status = deal.status ?? 'PENDING';
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.currency(deal.amount ?? 0),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  deal.currency ?? 'SYP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Property info
          if (deal.property != null) ...[
            _buildSectionTitle(context, 'العقار'),
            _buildInfoCard(context, [
              _buildInfoRow(Icons.home_work_outlined, 'الاسم', deal.property.title ?? '-'),
              _buildInfoRow(Icons.location_on_outlined, 'الموقع', '${deal.property.city ?? '-'}${deal.property.district != null ? ' - ${deal.property.district}' : ''}'),
              _buildInfoRow(Icons.attach_money, 'السعر', Formatters.currency(deal.property.price ?? 0)),
            ]),
            const SizedBox(height: 20),
          ],

          // Parties
          _buildSectionTitle(context, 'أطراف الصفقة'),
          _buildInfoCard(context, [
            if (deal.seller != null)
              _buildInfoRow(Icons.person_outline, 'البائع', deal.seller.fullName ?? '-'),
            if (deal.buyer != null)
              _buildInfoRow(Icons.person_outline, 'المشتري', deal.buyer.fullName ?? '-'),
            if (deal.agent != null)
              _buildInfoRow(Icons.badge_outlined, 'الوكيل', deal.agent.fullName ?? '-'),
          ]),
          const SizedBox(height: 20),

          // Financial details
          _buildSectionTitle(context, 'التفاصيل المالية'),
          _buildInfoCard(context, [
            _buildInfoRow(Icons.payments_outlined, 'المبلغ', Formatters.currency(deal.amount ?? 0)),
            _buildInfoRow(Icons.account_balance_wallet_outlined, 'العمولة', Formatters.currency(deal.commission ?? 0)),
            _buildInfoRow(Icons.check_circle_outline, 'المدفوع', Formatters.currency(deal.totalPaid ?? 0)),
            _buildInfoRow(Icons.pending_outlined, 'المتبقي', Formatters.currency((deal.amount ?? 0) - (deal.totalPaid ?? 0))),
          ]),
          const SizedBox(height: 20),

          // Dates
          if (deal.startDate != null || deal.endDate != null) ...[
            _buildSectionTitle(context, 'التواريخ'),
            _buildInfoCard(context, [
              if (deal.startDate != null)
                _buildInfoRow(Icons.calendar_today_outlined, 'تاريخ البداية', Formatters.date(deal.startDate!)),
              if (deal.endDate != null)
                _buildInfoRow(Icons.event_outlined, 'تاريخ الانتهاء', Formatters.date(deal.endDate!)),
              if (deal.createdAt != null)
                _buildInfoRow(Icons.access_time, 'تاريخ الإنشاء', Formatters.date(deal.createdAt!)),
            ]),
            const SizedBox(height: 20),
          ],

          // Notes
          if (deal.notes != null && deal.notes!.isNotEmpty) ...[
            _buildSectionTitle(context, 'ملاحظات'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(deal.notes!, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 20),
          ],

          // Payments
          _buildSectionTitle(context, 'المدفوعات'),
          deal.payments != null && deal.payments.isNotEmpty
              ? Column(
                  children: deal.payments.map<Widget>((payment) => _buildPaymentCard(context, payment)).toList(),
                )
              : const EmptyStateWidget(
                  message: 'لا توجد مدفوعات بعد',
                  icon: Icons.payment_outlined,
                ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, dynamic payment) {
    final payStatus = payment.status ?? 'PENDING';
    final payColor = _getStatusColor(payStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, size: 20, color: payColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.currency(payment.amount ?? 0), style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(payment.method ?? '-', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: payColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusLabel(payStatus),
              style: TextStyle(color: payColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      case 'IN_PROGRESS':
      case 'ACTIVE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'مكتمل';
      case 'PENDING':
        return 'قيد الانتظار';
      case 'CANCELLED':
        return 'ملغي';
      case 'IN_PROGRESS':
      case 'ACTIVE':
        return 'قيد التنفيذ';
      case 'PAID':
        return 'مدفوع';
      case 'FAILED':
        return 'فشل';
      default:
        return status;
    }
  }
}