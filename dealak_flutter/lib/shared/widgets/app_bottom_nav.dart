import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final role = auth.user?.role ?? 'BUYER';
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = _getNavItems(role);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items
                .map((item) => _NavItem(
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      label: item.label,
                      isActive: currentLocation == item.route,
                      onTap: () => context.go(item.route),
                      isDark: isDark,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<_NavItemData> _getNavItems(String role) {
    switch (role) {
      case 'ADMIN':
        return [
          _NavItemData(Icons.dashboard_outlined, Icons.dashboard, 'لوحة التحكم', RouteNames.adminDashboard),
          _NavItemData(Icons.home_work_outlined, Icons.home_work, 'العقارات', RouteNames.adminProperties),
          _NavItemData(Icons.people_outline, Icons.people, 'المستخدمين', RouteNames.adminUsers),
          _NavItemData(Icons.analytics_outlined, Icons.analytics, 'التقارير', RouteNames.adminReports),
          _NavItemData(Icons.person_outline, Icons.person, 'حسابي', RouteNames.profile),
        ];
      case 'AGENT':
        return [
          _NavItemData(Icons.home_outlined, Icons.home, 'الرئيسية', RouteNames.home),
          _NavItemData(Icons.home_work_outlined, Icons.home_work, 'عقاراتي', RouteNames.myProperties),
          _NavItemData(Icons.handshake_outlined, Icons.handshake, 'صفقاتي', RouteNames.deals),
          _NavItemData(Icons.chat_bubble_outline, Icons.chat_bubble, 'الرسائل', RouteNames.conversations),
          _NavItemData(Icons.person_outline, Icons.person, 'حسابي', RouteNames.profile),
        ];
      default:
        return [
          _NavItemData(Icons.home_outlined, Icons.home, 'الرئيسية', RouteNames.home),
          _NavItemData(Icons.search_outlined, Icons.search, 'بحث', RouteNames.search),
          _NavItemData(Icons.favorite_border, Icons.favorite, 'المفضلة', RouteNames.favorites),
          _NavItemData(Icons.chat_bubble_outline, Icons.chat_bubble, 'الرسائل', RouteNames.conversations),
          _NavItemData(Icons.person_outline, Icons.person, 'حسابي', RouteNames.profile),
        ];
    }
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItemData(this.icon, this.activeIcon, this.label, this.route);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
