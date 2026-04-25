import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final role = user?.role ?? 'BUYER';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user?.firstName.substring(0, 1) ?? '?',
                  style: const TextStyle(fontSize: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'مستخدم',
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(user?.email ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _roleLabel(role),
                  style: TextStyle(
                    color: _roleColor(role),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ..._buildRoleMenu(context, role, isDark),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('الإعدادات'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => context.push(RouteNames.settings),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('تسجيل الخروج',
                    style: TextStyle(color: AppColors.error)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleMenu(BuildContext context, String role, bool isDark) {
    final items = <_MenuItem>[];

    if (role == 'ADMIN') {
      items.addAll([
        _MenuItem(Icons.dashboard, 'لوحة التحكم', RouteNames.adminDashboard),
        _MenuItem(Icons.home_work_outlined, 'إدارة العقارات', RouteNames.adminProperties),
        _MenuItem(Icons.people_outline, 'إدارة المستخدمين', RouteNames.adminUsers),
        _MenuItem(Icons.analytics_outlined, 'التقارير والإحصائيات', RouteNames.adminReports),
        _MenuItem(Icons.edit, 'تعديل الملف الشخصي', RouteNames.editProfile),
        _MenuItem(Icons.notifications_outlined, 'الإشعارات', RouteNames.notifications),
      ]);
    } else if (role == 'AGENT') {
      items.addAll([
        _MenuItem(Icons.edit, 'تعديل الملف الشخصي', RouteNames.editProfile),
        _MenuItem(Icons.home_work_outlined, 'عقاراتي', RouteNames.myProperties),
        _MenuItem(Icons.handshake_outlined, 'صفقاتي', RouteNames.deals),
        _MenuItem(Icons.request_page_outlined, 'طلبات العملاء', RouteNames.requests),
        _MenuItem(Icons.bar_chart_outlined, 'إحصائياتي', RouteNames.agentStats),
        _MenuItem(Icons.notifications_outlined, 'الإشعارات', RouteNames.notifications),
      ]);
    } else if (role == 'SELLER') {
      items.addAll([
        _MenuItem(Icons.edit, 'تعديل الملف الشخصي', RouteNames.editProfile),
        _MenuItem(Icons.home_work_outlined, 'عقاراتي', RouteNames.myProperties),
        _MenuItem(Icons.handshake_outlined, 'صفقاتي', RouteNames.deals),
        _MenuItem(Icons.request_page_outlined, 'الطلبات', RouteNames.requests),
        _MenuItem(Icons.notifications_outlined, 'الإشعارات', RouteNames.notifications),
      ]);
    } else {
      items.addAll([
        _MenuItem(Icons.edit, 'تعديل الملف الشخصي', RouteNames.editProfile),
        _MenuItem(Icons.handshake_outlined, 'صفقاتي', RouteNames.deals),
        _MenuItem(Icons.request_page_outlined, 'طلباتي', RouteNames.requests),
        _MenuItem(Icons.notifications_outlined, 'الإشعارات', RouteNames.notifications),
      ]);
    }

    return items
        .map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => context.push(item.route),
            ))
        .toList();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'مدير النظام';
      case 'AGENT':
        return 'وكيل عقارات';
      case 'SELLER':
        return 'بائع';
      default:
        return 'مشتري';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return AppColors.error;
      case 'AGENT':
        return AppColors.primary;
      case 'SELLER':
        return AppColors.secondary;
      default:
        return AppColors.accent;
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem(this.icon, this.label, this.route);
}
