import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';

class AgentStatsScreen extends ConsumerWidget {
  const AgentStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final myPropertiesAsync = ref.watch(myPropertiesProvider(1));

    return Scaffold(
      appBar: AppBar(title: const Text('إحصائياتي')),
      body: myPropertiesAsync.when(
        data: (paginated) {
          final properties = paginated.data;
          final totalViews = properties.fold<int>(0, (sum, p) => sum + p.viewCount);
          final availableCount = properties.where((p) => p.status == 'AVAILABLE').length;
          final soldCount = properties.where((p) => p.status == 'SOLD').length;
          final rentedCount = properties.where((p) => p.status == 'RENTED').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملخص الأداء', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(icon: Icons.home_work, label: 'إجمالي العقارات', value: '${properties.length}', color: AppColors.primary, isDark: isDark),
                    _StatCard(icon: Icons.check_circle, label: 'عقارات متاحة', value: '$availableCount', color: AppColors.success, isDark: isDark),
                    _StatCard(icon: Icons.sell, label: 'عقارات مباعة', value: '$soldCount', color: AppColors.secondary, isDark: isDark),
                    _StatCard(icon: Icons.key, label: 'عقارات مؤجرة', value: '$rentedCount', color: AppColors.accent, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 24),
                Text('إحصائيات المشاهدات', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('$totalViews', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Text('إجمالي المشاهدات', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            properties.isNotEmpty ? (totalViews / properties.length).toStringAsFixed(1) : '0',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 4),
                          Text('متوسط المشاهدات', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (properties.isNotEmpty) ...[
                  Text('العقارات الأكثر مشاهدة', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...properties.take(5).map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('${p.city} - ${p.status}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${p.viewCount} مشاهدة', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري التحميل...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(myPropertiesProvider(1)),
        ),
      ),
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
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
