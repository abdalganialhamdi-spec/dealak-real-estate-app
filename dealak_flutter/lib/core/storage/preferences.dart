import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const _firstLaunchKey = 'first_launch';
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _notificationsKey = 'notifications_enabled';

  final SharedPreferences _prefs;

  Preferences(this._prefs);

  bool get isFirstLaunch => _prefs.getBool(_firstLaunchKey) ?? true;
  Future<void> setFirstLaunchDone() => _prefs.setBool(_firstLaunchKey, false);

  String get themeMode => _prefs.getString(_themeKey) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeKey, mode);

  String get locale => _prefs.getString(_localeKey) ?? 'ar';
  Future<void> setLocale(String locale) => _prefs.setString(_localeKey, locale);

  bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) => _prefs.setBool(_notificationsKey, enabled);
}
