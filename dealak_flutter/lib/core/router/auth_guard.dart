import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/core/router/route_names.dart';

class AuthGuard {
  final SecureStorage _storage;

  AuthGuard(this._storage);

  Future<String?> redirect(GoRouterState state) async {
    final hasToken = await _storage.hasToken();
    final userRole = await _storage.getUserRole();
    final isAuthRoute = [
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.onboarding,
      RouteNames.apiSettings,
    ].contains(state.matchedLocation);

    if (!hasToken && !isAuthRoute) {
      return RouteNames.login;
    }
    if (hasToken && isAuthRoute) {
      if (userRole == 'ADMIN') {
        return RouteNames.adminDashboard;
      }
      return RouteNames.home;
    }
    if (hasToken && userRole == 'ADMIN' && state.matchedLocation == RouteNames.home) {
      return RouteNames.adminDashboard;
    }
    if (hasToken && userRole != 'ADMIN') {
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      if (isAdminRoute) {
        return RouteNames.home;
      }
    }
    if (hasToken && userRole != 'AGENT' && userRole != 'ADMIN') {
      final isAgentRoute = state.matchedLocation.startsWith('/agent');
      if (isAgentRoute) {
        return RouteNames.home;
      }
    }
    return null;
  }
}