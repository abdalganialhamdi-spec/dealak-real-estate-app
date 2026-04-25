import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/router/auth_guard.dart';
import 'package:dealak_flutter/core/router/auth_listenable.dart';
import 'package:dealak_flutter/features/auth/screens/login_screen.dart';
import 'package:dealak_flutter/features/auth/screens/register_screen.dart';
import 'package:dealak_flutter/features/auth/screens/forgot_password_screen.dart';
import 'package:dealak_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:dealak_flutter/features/home/screens/home_screen.dart';
import 'package:dealak_flutter/features/property/screens/property_detail_screen.dart';
import 'package:dealak_flutter/features/property/screens/property_create_screen.dart';
import 'package:dealak_flutter/features/property/screens/property_list_screen.dart';
import 'package:dealak_flutter/features/search/screens/search_screen.dart';
import 'package:dealak_flutter/features/favorites/screens/favorites_screen.dart';
import 'package:dealak_flutter/features/messages/screens/conversations_screen.dart';
import 'package:dealak_flutter/features/messages/screens/chat_screen.dart';
import 'package:dealak_flutter/features/deals/screens/deals_list_screen.dart';
import 'package:dealak_flutter/features/deals/screens/deal_detail_screen.dart';
import 'package:dealak_flutter/features/profile/screens/profile_screen.dart';
import 'package:dealak_flutter/features/profile/screens/edit_profile_screen.dart';
import 'package:dealak_flutter/features/profile/screens/settings_screen.dart';
import 'package:dealak_flutter/features/profile/screens/my_properties_screen.dart';
import 'package:dealak_flutter/features/notifications/screens/notifications_screen.dart';
import 'package:dealak_flutter/features/requests/screens/requests_list_screen.dart';
import 'package:dealak_flutter/features/requests/screens/create_request_screen.dart';
import 'package:dealak_flutter/features/admin/screens/admin_dashboard_screen.dart';
import 'package:dealak_flutter/features/admin/screens/admin_properties_screen.dart';
import 'package:dealak_flutter/features/admin/screens/admin_property_form_screen.dart';
import 'package:dealak_flutter/shared/widgets/app_scaffold.dart';
import 'package:dealak_flutter/features/settings/screens/api_settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthGuard authGuard, AuthChangeNotifier authListenable) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.home,
    refreshListenable: authListenable,
    redirect: (context, state) => authGuard.redirect(state),
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.apiSettings,
        builder: (context, state) => const ApiSettingsPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: RouteNames.search,
            pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: RouteNames.favorites,
            pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesScreen()),
          ),
          GoRoute(
            path: RouteNames.conversations,
            pageBuilder: (context, state) => const NoTransitionPage(child: ConversationsScreen()),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '${RouteNames.propertyDetail}/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: RouteNames.propertyCreate,
        builder: (context, state) => const PropertyCreateScreen(),
      ),
      GoRoute(
        path: RouteNames.propertyList,
        builder: (context, state) => const PropertyListScreen(),
      ),
      GoRoute(
        path: '${RouteNames.chat}/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: RouteNames.deals,
        builder: (context, state) => const DealsListScreen(),
      ),
      GoRoute(
        path: '${RouteNames.dealDetail}/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DealDetailScreen(dealId: id);
        },
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.myProperties,
        builder: (context, state) => const MyPropertiesScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.requests,
        builder: (context, state) => const RequestsListScreen(),
      ),
      GoRoute(
        path: RouteNames.createRequest,
        builder: (context, state) => const CreateRequestScreen(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.adminProperties,
        builder: (context, state) => const AdminPropertiesScreen(),
      ),
      GoRoute(
        path: '${RouteNames.adminPropertyForm}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] == 'new' ? null : int.tryParse(state.pathParameters['id']!);
          return AdminPropertyFormScreen(propertyId: id);
        },
      ),
    ],
  );
}
