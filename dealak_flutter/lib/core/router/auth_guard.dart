import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/core/router/route_names.dart';

class AuthGuard {
  final SecureStorage _storage;

  AuthGuard(this._storage);

  Future<String?> redirect(GoRouterState state) async {
    final hasToken = await _storage.hasToken();
    final isAuthRoute = [
      RouteNames.login,
      RouteNames.register,
      RouteNames.forgotPassword,
      RouteNames.onboarding,
    ].contains(state.matchedLocation);

    if (!hasToken && !isAuthRoute) {
      return RouteNames.login;
    }
    if (hasToken && isAuthRoute) {
      return RouteNames.home;
    }
    return null;
  }
}
