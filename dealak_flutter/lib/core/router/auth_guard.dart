import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/core/router/route_names.dart';

class AuthGuard {
  final SecureStorage _storage;

  AuthGuard(this._storage);

  Future<String?> redirect(GoRouterState state) async {
    return null;
  }
}
