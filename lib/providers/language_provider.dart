import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/constants.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    // If we're calling this before Hive is initialized, it might throw
    // but in main.dart we ensure Hive is open first.
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      final langCode = box.get('language_code', defaultValue: 'en');
      _currentLocale = Locale(langCode);
      notifyListeners();
    } catch (e) {
      // Ignored for safe fallback
    }
  }

  Future<void> changeLanguage(String langCode) async {
    if (_currentLocale.languageCode == langCode) return;
    _currentLocale = Locale(langCode);
    try {
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('language_code', langCode);
    } catch (e) {
      // Ignored
    }
    notifyListeners();
  }
}
