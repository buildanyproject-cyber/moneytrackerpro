import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/budget_provider.dart';
import '../../core/localization.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/goal_provider.dart';
import '../../database/hive_database.dart';
import '../backup_restore/backup_restore_screen.dart';
import '../reminder/reminder_screen.dart';
import '../wallet/wallet_screen.dart';
import '../category/category_screen.dart';
import '../budget/budget_screen.dart';

// ============================================================
// Settings Screen
// ============================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, LanguageProvider>(
        builder: (context, settings, language, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ListView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            children: [
              _SectionHeader(title: 'Preferences'),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: settings.themeMode.name.capitalize(),
                onTap: () => _showThemeDialog(context, settings),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                title: context.tr('Currency') == 'Currency'
                    ? 'Currency'
                    : context.tr('currency'),
                subtitle: settings.currency,
                onTap: () => _showCurrencyDialog(context, settings),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: context.tr('language'),
                subtitle: language.currentLocale.languageCode.toUpperCase(),
                onTap: () => _showLanguageDialog(context, language),
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Management'),
              _SettingsTile(
                icon: Icons.category_outlined,
                title: 'Categories',
                subtitle: 'Manage income and expense categories',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()),
                ),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallets',
                subtitle: 'Manage your accounts and balances',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                ),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.track_changes_outlined,
                title: 'Budgets',
                subtitle: 'Set and track monthly limits',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                ),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Reminders',
                subtitle: 'Manage bill and payment alerts',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReminderScreen()),
                ),
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Security & Data'),
              SwitchListTile(
                title: const Text(
                  'Biometric Lock',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Require Face ID / Touch ID to open'),
                value: settings.biometricEnabled,
                onChanged: (val) {
                  settings.setBiometric(val);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                  ),
                ),
                activeThumbColor: AppColors.primary,
              ),
              _SettingsTile(
                icon: Icons.pin_outlined,
                title: settings.hasPin ? 'Reset PIN' : 'Set PIN',
                subtitle: settings.hasPin
                    ? 'Change or remove your fallback PIN'
                    : 'Set a fallback PIN for app unlock',
                onTap: () => _showPinDialog(context, settings),
                isDark: isDark,
              ),
              _SettingsTile(
                icon: Icons.cloud_sync_outlined,
                title: 'Backup & Restore',
                subtitle: 'Google Drive sync & Local backup',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BackupRestoreScreen(),
                  ),
                ),
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'About'),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: AppConstants.appVersion,
                onTap: () {},
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Danger Zone'),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  'Clear All Data',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(
                  'Erase all transactions, budgets, reminders & goals. Categories and wallets are kept.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: () => _showClearDataConfirmation(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions, budgets, reminders, and goals. Your wallets (with balance reset to 0) and categories will be preserved.\n\nThis action cannot be undone. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // 1. Clear Database
              await HiveDatabase().clearAllData();

              // 2. Reload providers so the UI syncs (wallets & categories remain)
              if (context.mounted) {
                Provider.of<WalletProvider>(
                  context,
                  listen: false,
                ).loadWallets();
                Provider.of<TransactionProvider>(
                  context,
                  listen: false,
                ).clearData();
                Provider.of<BudgetProvider>(context, listen: false).clearData();
                Provider.of<GoalProvider>(context, listen: false).clearData();
              }

              // Hide loading
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Yes, Clear All'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(mode.name.capitalize()),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (val) {
                if (val != null) {
                  settings.setThemeMode(val);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider language) {
    final Map<String, String> languages = {
      'en': 'English',
      'es': 'Español (Spanish)',
      'as': 'অসমীয়া (Assamese)',
      'bn': 'বাংলা (Bengali)',
      'brx': 'बड़ो (Bodo)',
      'doi': 'डोगरी (Dogri)',
      'gu': 'ગુજરાતી (Gujarati)',
      'hi': 'हिन्दी (Hindi)',
      'kn': 'ಕನ್ನಡ (Kannada)',
      'ks': 'کأشُر (Kashmiri)',
      'kok': 'कोंकणी (Konkani)',
      'mai': 'मैथिली (Maithili)',
      'ml': 'മലയാളം (Malayalam)',
      'mni': 'ꯃꯤꯇꯩꯂꯣꯟ (Manipuri)',
      'mr': 'मराठी (Marathi)',
      'ne': 'नेपाली (Nepali)',
      'or': 'ଓଡ଼ିଆ (Odia)',
      'pa': 'ਪੰਜਾਬੀ (Punjabi)',
      'sa': 'संस्कृतम् (Sanskrit)',
      'sat': 'ᱥᱟᱱᱛᱟᱲᱤ (Santali)',
      'sd': 'سنڌي (Sindhi)',
      'ta': 'தமிழ் (Tamil)',
      'te': 'తెలుగు (Telugu)',
      'ur': 'اردو (Urdu)',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('language')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final entry = languages.entries.elementAt(index);
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: language.currentLocale.languageCode,
                onChanged: (val) {
                  if (val != null) {
                    language.changeLanguage(val);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider settings) {
    // A simple list for demonstration. Real app should have a comprehensive list.
    final currencies = ['\$', '€', '£', '₹', '¥', 'A\$', 'C\$'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final c = currencies[index];
              return InkWell(
                onTap: () {
                  settings.setCurrency(c);
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: settings.currency == c
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.3),
                      width: settings.currency == c ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: settings.currency == c
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : null,
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context, SettingsProvider settings) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(settings.hasPin ? 'Reset PIN' : 'Set PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (settings.hasPin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove PIN'),
                    onPressed: () {
                      settings.resetPin();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PIN removed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'New PIN (4-6 digits)',
                  counterText: '',
                  errorText: errorText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinController.text;
                final confirm = confirmController.text;
                if (pin.length < 4) {
                  setDialogState(
                    () => errorText = 'PIN must be at least 4 digits',
                  );
                  return;
                }
                if (pin != confirm) {
                  setDialogState(() => errorText = 'PINs do not match');
                  return;
                }
                settings.setPin(pin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN set successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
