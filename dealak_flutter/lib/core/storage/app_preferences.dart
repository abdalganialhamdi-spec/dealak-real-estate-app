import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AppPreferences {
  final SharedPreferences _prefs;
  AppPreferences(this._prefs);

  bool get isApiConfigured => _prefs.getBool(AppConstants.prefApiConfigured) ?? false;

  String get apiHost => _prefs.getString(AppConstants.prefApiHost) ?? AppConstants.defaultHost;
  String get apiPort => _prefs.getString(AppConstants.prefApiPort) ?? AppConstants.defaultPort;

  String get baseUrl => 'http://$apiHost:$apiPort${AppConstants.apiPrefix}';

  Future<void> saveApiConfig(String host, String port) async {
    await _prefs.setString(AppConstants.prefApiHost, host);
    await _prefs.setString(AppConstants.prefApiPort, port);
    await _prefs.setBool(AppConstants.prefApiConfigured, true);
  }

  Future<void> clearApiConfig() async {
    await _prefs.remove(AppConstants.prefApiHost);
    await _prefs.remove(AppConstants.prefApiPort);
    await _prefs.setBool(AppConstants.prefApiConfigured, false);
  }
}
