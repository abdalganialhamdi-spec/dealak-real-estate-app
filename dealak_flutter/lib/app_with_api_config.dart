import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/screens/api_settings_screen.dart';
import 'app.dart';
import 'providers/auth_provider.dart';

class DealakAppWithApiConfig extends ConsumerStatefulWidget {
  const DealakAppWithApiConfig({super.key});

  @override
  ConsumerState<DealakAppWithApiConfig> createState() => _DealakAppWithApiConfigState();
}

class _DealakAppWithApiConfigState extends ConsumerState<DealakAppWithApiConfig> {
  bool _isLoading = true;
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final prefs = await ref.read(appPreferencesProvider.future);
    if (prefs.isApiConfigured && mounted) {
      final dioClient = ref.read(dioClientProvider);
      dioClient.updateBaseUrl(prefs.baseUrl);
    }
    setState(() {
      _isConfigured = prefs.isApiConfigured;
      _isLoading = false;
    });
  }

  void _onApiConfigured() {
    setState(() => _isConfigured = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (!_isConfigured) {
      final prefsAsync = ref.watch(appPreferencesProvider);
      return prefsAsync.when(
        loading: () => const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        error: (e, _) => const MaterialApp(
          home: Scaffold(body: Center(child: Text('Error loading preferences'))),
        ),
        data: (prefs) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: ApiSettingsScreen(
            prefs: prefs,
            onConfigured: _onApiConfigured,
          ),
        ),
      );
    }

    return const DealakApp();
  }
}
