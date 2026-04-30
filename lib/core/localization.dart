import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'indian_translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'dashboard': 'Dashboard',
      'total_balance': 'Total Balance',
      'income': 'Income',
      'expense': 'Expense',
      'recent_transactions': 'Recent Transactions',
      'add_transaction': 'Add Transaction',
      'goals': 'Goals',
      'wallets': 'Wallets',
      'categories': 'Categories',
      'settings': 'Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'no_transactions_yet': 'No Transactions Yet',
      'see_all': 'See All',
      'main': 'MAIN',
      'finance': 'FINANCE',
      'tools': 'TOOLS',
      'legal_info': 'LEGAL & INFO',
      'transactions': 'Transactions',
      'analytics': 'Analytics',
      'budgets': 'Budgets',
      'reminders': 'Reminders',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      'about_developer': 'About Developer',
    },
    'hi': {
      'dashboard': 'डैशबोर्ड',
      'total_balance': 'कुल शेष',
      'income': 'आय',
      'expense': 'खर्च',
      'recent_transactions': 'हाल के लेनदेन',
      'add_transaction': 'लेनदेन जोड़ें',
      'goals': 'लक्ष्य',
      'wallets': 'वॉलेट',
      'categories': 'श्रेणियाँ',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'dark_mode': 'डार्क मोड',
      'no_transactions_yet': 'अभी कोई लेनदेन नहीं',
      'see_all': 'सभी देखें',
      'main': 'मुख्य',
      'finance': 'वित्त',
      'tools': 'उपकरण',
      'legal_info': 'कानूनी जानकारी',
      'transactions': 'लेनदेन',
      'analytics': 'विश्लेषण',
      'budgets': 'बजट',
      'reminders': 'अनुस्मारक',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_conditions': 'नियम और शर्तें',
      'about_developer': 'डेवलपर के बारे में',
    },
    'es': {
      'dashboard': 'Tablero',
      'total_balance': 'Saldo Total',
      'income': 'Ingresos',
      'expense': 'Gastos',
      'recent_transactions': 'Transacciones Recientes',
      'add_transaction': 'Añadir Transacción',
      'goals': 'Metas',
      'wallets': 'Billeteras',
      'categories': 'Categorías',
      'settings': 'Ajustes',
      'language': 'Idioma',
      'dark_mode': 'Modo Oscuro',
      'no_transactions_yet': 'Aún no hay transacciones',
      'see_all': 'Ver Todo',
      'main': 'PRINCIPAL',
      'finance': 'FINANZAS',
      'tools': 'HERRAMIENTAS',
      'legal_info': 'LEGAL E INFO',
      'transactions': 'Transacciones',
      'analytics': 'Analítica',
      'budgets': 'Presupuestos',
      'reminders': 'Recordatorios',
      'privacy_policy': 'Política de Privacidad',
      'terms_conditions': 'Términos y Condiciones',
      'about_developer': 'Sobre el Desarrollador',
    },
    ...IndianTranslations.data,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'en',
    'hi',
    'es',
    'as',
    'bn',
    'brx',
    'doi',
    'gu',
    'kn',
    'ks',
    'kok',
    'mai',
    'ml',
    'mni',
    'mr',
    'ne',
    'or',
    'pa',
    'sa',
    'sat',
    'sd',
    'ta',
    'te',
    'ur',
  ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.get(key) ?? key;
}

// Fallbacks for languages not natively supported by flutter_localizations
// This ensures that Material/Cupertino widgets don't crash complaining about missing delegates
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}

class FallbackWidgetsLocalizationDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) async =>
      const DefaultWidgetsLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) =>
      false;
}
