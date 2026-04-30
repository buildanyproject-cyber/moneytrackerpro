import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/themes.dart';
import 'database/hive_database.dart';
import 'services/notification_service.dart';

import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/language_provider.dart';
import 'providers/goal_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  try {
    // 1. Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Initialize the local database (Hive)
    await HiveDatabase().init();

    // 3. Initialize notifications
    final notifService = NotificationService();
    await notifService.init();

    // 4. Run App wrapped in Providers
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: const MoneyTrackerApp(),
      ),
    );
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF2C2154),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'App Startup Failed',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, LanguageProvider>(
      builder: (context, settings, language, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          locale: language.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('es'),
            Locale('as'),
            Locale('bn'),
            Locale('brx'),
            Locale('doi'),
            Locale('gu'),
            Locale('kn'),
            Locale('ks'),
            Locale('kok'),
            Locale('mai'),
            Locale('ml'),
            Locale('mni'),
            Locale('mr'),
            Locale('ne'),
            Locale('or'),
            Locale('pa'),
            Locale('sa'),
            Locale('sat'),
            Locale('sd'),
            Locale('ta'),
            Locale('te'),
            Locale('ur'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            // Fallbacks
            FallbackMaterialLocalizationDelegate(),
            FallbackCupertinoLocalizationDelegate(),
            FallbackWidgetsLocalizationDelegate(),
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
