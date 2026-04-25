import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

class AuthChangeNotifier extends ChangeNotifier {
  final Ref _ref;
  ProviderSubscription<AuthState>? _subscription;

  AuthChangeNotifier(this._ref) {
    _subscription = _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}

final authListenableProvider = Provider<AuthChangeNotifier>((ref) {
  final notifier = AuthChangeNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});