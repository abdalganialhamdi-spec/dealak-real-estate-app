import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/screens/api_settings_screen.dart';

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
    setState(() {
      _isConfigured = _prefs.isApiConfigured;
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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: ApiSettingsScreen(
          prefs: _prefs,
          onConfigured: _onApiConfigured,
        ),
      );
    }

    return const DealakAppContent();
  }
}

class DealakAppContent extends StatelessWidget {
  const DealakAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DEALAK'),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('متصل بالسيرفر', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
