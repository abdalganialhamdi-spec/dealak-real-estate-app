import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/theme/app_theme.dart';
import 'package:dealak_flutter/core/router/app_router.dart';
import 'package:dealak_flutter/core/router/auth_guard.dart';
import 'package:dealak_flutter/core/storage/secure_storage.dart';
import 'package:dealak_flutter/providers/theme_provider.dart';
import 'package:dealak_flutter/providers/locale_provider.dart';

class DealakApp extends ConsumerWidget {
  const DealakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final authGuard = AuthGuard(SecureStorage());
    final router = createRouter(authGuard);

    return MaterialApp.router(
      title: 'DEALAK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(locale),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
