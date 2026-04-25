import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardAsync = ref.watch(adminDashboardProvider);
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminDashboardProvider);
              ref.invalidate(adminReportsProvider);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => reportsAsync.when(
          data: (reports) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminDashboardProvider);
              ref.invalidate(adminReportsProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinancialStats(context, dashboard, isDark),
                  const SizedBox(height: 24),
                  _buildMonthlyDeals(context, reports, isDark),
                  const SizedBox(height: 24),
                  _buildPropertiesByCity(context, reports, isDark),
                  const SizedBox(height: 24),
                  _buildPropertiesByType(context, reports, isDark),
                ],
              ),
            ),
          ),
          loading: () => const LoadingWidget(message: 'جاري تحميل التقارير...'),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(adminReportsProvider),
          ),
        ),
        loading: () => const LoadingWidget(message: 'جاري التحميل...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
      ),
    );
  }

  Widget _buildFinancialStats(BuildContext context, Map<String, dynamic> dashboard, bool isDark) {
    final totalRevenue = dashboard['total_revenue'] ?? 0;
    final activeDeals = dashboard['active_deals'] ?? 0;
    final completedDeals = dashboard['completed_deals'] ?? dashboard['deals_count'] ?? 0;
    final availableProperties = dashboard['available_properties'] ?? dashboard['properties_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إحصائيات الفوترة والمحاسبة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              icon: Icons.attach_money,
              label: 'إجمالي الإيرادات',
              value: Formatters.currency(totalRevenue is num ? totalRevenue.toDouble() : 0),
              color: AppColors.success,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.handshake,
              label: 'الصفقات الجارية',
              value: '$activeDeals',
              color: AppColors.accent,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.check_circle,
              label: 'الصفقات المكتملة',
              value: '$completedDeals',
              color: AppColors.primary,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.home_work,
              label: 'العقارات المتاحة',
              value: '$availableProperties',
              color: AppColors.secondary,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyDeals(BuildContext context, Map<String, dynamic> reports, bool isDark) {
    final monthlyDeals = reports['monthly_deals'];
    if (monthlyDeals is! List || monthlyDeals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الصفقات الشهرية', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
          child: Column(
            children: monthlyDeals.take(12).map((item) {
              final month = item is Map ? (item['month'] ?? item['date'] ?? '').toString() : '';
               final count = item is Map ? (item['count'] ?? item['total'] ?? 0) : 0;
               return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(month, style: const TextStyle(fontSize: 13))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (count is num ? count.toDouble() : 0) > 0 ? 1.0 : 0.1,
                          backgroundColor: isDark ? AppColors.dividerDark : Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$count صفقة',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesByCity(BuildContext context, Map<String, dynamic> reports, bool isDark) {
    final byCity = reports['properties_by_city'];
    if (byCity is! List || byCity.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('توزيع العقارات حسب المدينة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: byCity.take(10).map((item) {
            final city = item is Map ? (item['city'] ?? item['name'] ?? '').toString() : '';
            final count = item is Map ? (item['count'] ?? item['total'] ?? 0) : 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$city: $count', style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPropertiesByType(BuildContext context, Map<String, dynamic> reports, bool isDark) {
    final byType = reports['properties_by_type'];
    if (byType is! List || byType.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('توزيع العقارات حسب النوع', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
          child: Column(
            children: byType.map((item) {
              final type = item is Map ? (item['type'] ?? item['property_type'] ?? item['name'] ?? '').toString() : '';
              final count = item is Map ? (item['count'] ?? item['total'] ?? 0) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(Formatters.propertyType(type), style: const TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (count is num ? count.toDouble() : 0) > 0 ? 1.0 : 0.1,
                          backgroundColor: isDark ? AppColors.dividerDark : Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                          minHeight: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
