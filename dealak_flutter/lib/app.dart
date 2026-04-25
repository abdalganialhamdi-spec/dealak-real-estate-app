import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/theme/app_theme.dart';
import 'package:dealak_flutter/core/router/app_router.dart';
import 'package:dealak_flutter/core/router/auth_guard.dart';
import 'package:dealak_flutter/core/router/auth_listenable.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';
import 'package:dealak_flutter/providers/theme_provider.dart';
import 'package:dealak_flutter/providers/locale_provider.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(
    AuthGuard(ref.read(secureStorageProvider)),
    ref.read(authListenableProvider),
  );
});

class DealakApp extends ConsumerWidget {
  const DealakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

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
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
