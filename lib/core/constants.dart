import 'package:flutter/material.dart';

// ============================================================
// App-wide constants for MoneyTracker Pro
// ============================================================

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'MoneyTracker Pro';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Finance, Simplified';

  // Hive box names
  static const String transactionBox = 'transactions';
  static const String categoryBox = 'categories';
  static const String walletBox = 'wallets';
  static const String budgetBox = 'budgets';
  static const String reminderBox = 'reminders';
  static const String settingsBox = 'settings';
  static const String goalBox = 'goals';

  // Secure storage keys
  static const String pinKey = 'app_pin';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'currency_symbol';

  // Google Drive
  static const String backupFileName = 'moneytracker_backup.json';
  static const String backupMimeType = 'application/json';

  // Default currency
  static const String defaultCurrency = '₹';

  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String monthFormat = 'MMMM yyyy';
  static const String timeFormat = 'hh:mm a';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

// ============================================================
// Color palette for the fintech UI
// ============================================================

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // Semantic colors
  static const Color income = Color(0xFF00B894);
  static const Color incomeLight = Color(0xFF55EFC4);
  static const Color expense = Color(0xFFE17055);
  static const Color expenseLight = Color(0xFFFAB1A0);
  static const Color budget = Color(0xFF0984E3);
  static const Color budgetLight = Color(0xFF74B9FF);

  // Neutrals
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color divider = Color(0xFFDFE6E9);

  // Dark mode
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkDivider = Color(0xFF30363D);

  // Accent / category colors
  static const List<Color> categoryColors = [
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFE17055),
    Color(0xFF0984E3),
    Color(0xFFFDAA5E),
    Color(0xFFE84393),
    Color(0xFF00CEC9),
    Color(0xFFFF7675),
    Color(0xFF55A3F5),
    Color(0xFF95E1D3),
    Color(0xFFF8B739),
    Color(0xFFC44569),
    Color(0xFF546DE5),
    Color(0xFF3DC1D3),
    Color(0xFFF78FB3),
    Color(0xFF778BEB),
  ];

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE17055), Color(0xFFFAB1A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ============================================================
// Enums
// ============================================================

enum TransactionType { income, expense }

enum RecurrenceType { daily, weekly, monthly, yearly }

enum ThemeModeOption { light, dark, system }

// Default category icons mapping
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> icons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'health': Icons.medical_services,
    'education': Icons.school,
    'bills': Icons.receipt_long,
    'salary': Icons.account_balance_wallet,
    'freelance': Icons.work,
    'investment': Icons.trending_up,
    'gift': Icons.card_giftcard,
    'travel': Icons.flight,
    'groceries': Icons.local_grocery_store,
    'rent': Icons.home,
    'utilities': Icons.electrical_services,
    'subscription': Icons.subscriptions,
    'other': Icons.category,
  };

  static IconData getIcon(String name) {
    return icons[name.toLowerCase()] ?? Icons.category;
  }
}
