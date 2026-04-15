import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return BottomNavigationBar(
      currentIndex: _currentIndex(currentLocation),
      onTap: (index) => _onTap(context, index),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الرسائل'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
      ],
    );
  }

  int _currentIndex(String location) {
    if (location == RouteNames.home) return 0;
    if (location == RouteNames.search) return 1;
    if (location == RouteNames.favorites) return 2;
    if (location == RouteNames.conversations) return 3;
    if (location == RouteNames.profile) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final routes = [RouteNames.home, RouteNames.search, RouteNames.favorites, RouteNames.conversations, RouteNames.profile];
    context.go(routes[index]);
  }
}
