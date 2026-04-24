import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/screens/api_settings_screen.dart';
import 'app.dart';
import 'providers/auth_provider.dart';

class DealakAppWithApiConfig extends StatefulWidget {
  const DealakAppWithApiConfig({super.key});

  @override
  State<DealakAppWithApiConfig> createState() => _DealakAppWithApiConfigState();
}

class _DealakAppWithApiConfigState extends State<DealakAppWithApiConfig> {
  late AppPreferences _prefs;
  bool _isLoading = true;
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = AppPreferences(prefs);
    if (_prefs.isApiConfigured && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final container = ProviderScope.containerOf(context);
        final dioClient = container.read(dioClientProvider);
        dioClient.updateBaseUrl(_prefs.baseUrl);
      });
    }
    setState(() {
      _isConfigured = _prefs.isApiConfigured;
      _isLoading = false;
    });
  }

  void _onApiConfigured() {
    final container = ProviderScope.containerOf(context);
    final dioClient = container.read(dioClientProvider);
    dioClient.updateBaseUrl(_prefs.baseUrl);

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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: ApiSettingsScreen(
          prefs: _prefs,
          onConfigured: _onApiConfigured,
        ),
      );
    }

    return const DealakApp();
  }
}
