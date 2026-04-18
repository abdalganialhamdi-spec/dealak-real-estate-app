import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminDashboardProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.invalidate(adminDashboardProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(data, isDark),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, isDark),
                  const SizedBox(height: 24),
                  _buildRecentProperties(context, isDark),
                  const SizedBox(height: 24),
                  _buildRecentUsers(context, isDark),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري التحميل...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> data, bool isDark) {
    final propertiesCount = data['properties_count'] ?? 0;
    final usersCount = data['users_count'] ?? 0;
    final dealsCount = data['deals_count'] ?? 0;
    final pendingCount = data['pending_properties_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إحصائيات عامة', style: Theme.of(context).textTheme.titleLarge),
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
              icon: Icons.home_work,
              label: 'العقارات',
              value: '$propertiesCount',
              color: AppColors.primary,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.people,
              label: 'المستخدمين',
              value: '$usersCount',
              color: AppColors.accent,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.handshake,
              label: 'الصفقات',
              value: '$dealsCount',
              color: AppColors.secondary,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.pending_actions,
              label: 'قيد المراجعة',
              value: '$pendingCount',
              color: AppColors.warning,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_home,
                label: 'إضافة عقار',
                onTap: () => context.push('${RouteNames.adminPropertyForm}/new'),
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.list_alt,
                label: 'العقارات',
                onTap: () => context.push(RouteNames.adminProperties),
                color: AppColors.accent,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.people_outline,
                label: 'المستخدمين',
                onTap: () {},
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.analytics,
                label: 'التقارير',
                onTap: () {},
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentProperties(BuildContext context, bool isDark) {
    final params = <String, dynamic>{'page': 1, 'per_page': 5, 'sort_by': 'created_at', 'sort_dir': 'desc'};
    final propertiesAsync = ref.watch(adminPropertiesProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('أحدث العقارات', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.push(RouteNames.adminProperties),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        propertiesAsync.when(
          data: (paginated) {
            final properties = paginated.data;
            if (properties.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('لا توجد عقارات', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ),
              );
            }
            return Column(
              children: properties.map((property) => _PropertyListItem(property: property, isDark: isDark)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRecentUsers(BuildContext context, bool isDark) {
    final usersAsync = ref.watch(adminUsersProvider({'page': 1, 'per_page': 5}));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('أحدث المستخدمين', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        usersAsync.when(
          data: (users) {
            if (users.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('لا توجد مستخدمين', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ),
              );
            }
            return Column(
              children: users.map((user) => _UserListItem(user: user, isDark: isDark)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const SizedBox.shrink(),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDark;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final dynamic property;
  final bool isDark;

  const _PropertyListItem({required this.property, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final title = property['title'] ?? '';
    final price = property['price'] ?? 0;
    final city = property['city'] ?? '';
    final status = property['status'] ?? 'AVAILABLE';

    Color getStatusColor(String status) {
      switch (status) {
        case 'AVAILABLE':
          return AppColors.available;
        case 'SOLD':
          return AppColors.sold;
        case 'RENTED':
          return AppColors.rent;
        case 'PENDING':
          return AppColors.pending;
        default:
          return Colors.grey;
      }
    }

    return Container(
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${Formatters.currency(price)} - $city', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(Formatters.status(status), style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _UserListItem({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] ?? user['name'] ?? '';
    final email = user['email'] ?? '';
    final isActive = user['is_active'] ?? user['is_verified'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isActive ? AppColors.success : AppColors.error,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }
}
