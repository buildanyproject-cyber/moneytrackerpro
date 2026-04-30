import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../database/hive_database.dart';

// ============================================================
// Settings Provider — Theme mode, currency, and app settings
// ============================================================

class SettingsProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();

  ThemeMode _themeMode = ThemeMode.system;
  String _currency = AppConstants.defaultCurrency;
  bool _isFirstLaunch = true;
  bool _biometricEnabled = false;
  bool _hasPin = false;

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get biometricEnabled => _biometricEnabled;
  bool get hasPin => _hasPin;

  void loadSettings() {
    final themeStr = _db.getSetting(AppConstants.themeKey);
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    _currency =
        _db.getSetting(AppConstants.currencyKey) ??
        AppConstants.defaultCurrency;
    _isFirstLaunch = _db.getSetting(AppConstants.isFirstLaunchKey) ?? true;
    _biometricEnabled =
        _db.getSetting(AppConstants.biometricEnabledKey) ?? false;

    final savedPin = _db.getSetting(AppConstants.pinKey);
    _hasPin = savedPin != null && savedPin.toString().isNotEmpty;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String str;
    switch (mode) {
      case ThemeMode.light:
        str = 'light';
        break;
      case ThemeMode.dark:
        str = 'dark';
        break;
      default:
        str = 'system';
    }
    await _db.setSetting(AppConstants.themeKey, str);
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _currency = symbol;
    await _db.setSetting(AppConstants.currencyKey, symbol);
    notifyListeners();
  }

  Future<void> setFirstLaunchDone() async {
    _isFirstLaunch = false;
    await _db.setSetting(AppConstants.isFirstLaunchKey, false);
    notifyListeners();
  }

  Future<void> setBiometric(bool enabled) async {
    _biometricEnabled = enabled;
    await _db.setSetting(AppConstants.biometricEnabledKey, enabled);
    notifyListeners();
  }

  // ─────────── PIN Management ───────────

  Future<void> setPin(String pin) async {
    await _db.setSetting(AppConstants.pinKey, pin);
    _hasPin = true;
    notifyListeners();
  }

  bool verifyPin(String pin) {
    final savedPin = _db.getSetting(AppConstants.pinKey);
    return savedPin != null && savedPin.toString() == pin;
  }

  Future<void> resetPin() async {
    await _db.setSetting(AppConstants.pinKey, null);
    _hasPin = false;
    notifyListeners();
  }
}
