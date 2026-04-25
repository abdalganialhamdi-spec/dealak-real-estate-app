import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';
import 'package:dealak_flutter/core/constants/app_constants.dart';

class ApiSettingsPage extends ConsumerStatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  ConsumerState<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends ConsumerState<ApiSettingsPage> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isTesting = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _portController = TextEditingController();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final prefsAsync = ref.read(appPreferencesProvider);
    prefsAsync.whenData((prefs) {
      _hostController.text = prefs.apiHost;
      _portController.text = prefs.apiPort;
    });
  }

  Future<void> _testAndSave() async {
    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _success = false;
    });

    final host = _hostController.text.trim();
    final port = _portController.text.trim();

    if (host.isEmpty || port.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى تعبئة جميع الحقول';
        _isTesting = false;
      });
      return;
    }

    final ok = await _testConnection(host, port);

    if (ok) {
      final prefsAsync = ref.read(appPreferencesProvider);
      final prefs = prefsAsync.value;
      if (prefs != null) {
        await prefs.saveApiConfig(host, port);
        final dioClient = ref.read(dioClientProvider);
        dioClient.updateBaseUrl('http://$host:$port${AppConstants.apiPrefix}');
      }
      setState(() {
        _success = true;
        _isTesting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'فشل الاتصال بالسيرفر\nتأكد من أن السيرفر يعمل على $host:$port';
        _isTesting = false;
      });
    }
  }

  Future<bool> _testConnection(String host, String port) async {
    try {
      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final url = 'http://$host:$port/api/v1/health';
      final response = await testDio.get(url);
      return response.statusCode == 200;
    } catch (_) {
      try {
        final testDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));
        final url = 'http://$host:$port/api/v1/properties?limit=1';
        final response = await testDio.get(url);
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الاتصال')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'قم بتغيير عنوان IP ومنفذ السيرفر للاتصال بالخادم المحلي',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _hostController,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'عنوان السيرفر (IP / Domain)',
                hintText: '192.168.1.5',
                prefixIcon: const Icon(Icons.dns),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'رقم المنفذ (Port)',
                hintText: '8000',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'http://${_hostController.text}:${_portController.text}/api/v1',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
              ),
            if (_success)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('تم الاتصال بنجاح', style: TextStyle(color: Colors.green, fontSize: 14)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isTesting ? null : _testAndSave,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_isTesting ? 'جاري الاختبار...' : 'اختبار الاتصال والحفظ'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
