import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/storage/app_preferences.dart';

class ApiSettingsScreen extends StatefulWidget {
  final AppPreferences prefs;
  final VoidCallback onConfigured;

  const ApiSettingsScreen({
    super.key,
    required this.prefs,
    required this.onConfigured,
  });

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  bool _isTesting = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.prefs.apiHost);
    _portController = TextEditingController(text: widget.prefs.apiPort);
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
      await widget.prefs.saveApiConfig(host, port);
      setState(() {
        _success = true;
        _isTesting = false;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onConfigured();
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
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final url = 'http://$host:$port/api/v1/properties?limit=1';
      final response = await testDio.get(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.settings_ethernet, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('إعدادات الاتصال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('حدد عنوان ومنفذ السيرفر', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 32),
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('تم الاتصال بنجاح ✓', style: TextStyle(color: Colors.green, fontSize: 14)),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isTesting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('اختبار الاتصال والحفظ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
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
