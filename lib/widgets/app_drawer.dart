import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/localization.dart';
import '../providers/settings_provider.dart';
import '../screens/add_transaction/add_transaction_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/category/category_screen.dart';
import '../screens/reminder/reminder_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../screens/more/privacy_policy_screen.dart';
import '../screens/more/terms_screen.dart';
import '../screens/more/about_developer_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v${AppConstants.appVersion} • ${AppConstants.appTagline}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeader(title: context.tr('main')),
                  _DrawerItem(
                    icon: Icons.dashboard,
                    title: context.tr('dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              const DashboardScreen(initialIndex: 0),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long,
                    title: context.tr('transactions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              const DashboardScreen(initialIndex: 1),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    title: context.tr('add_transaction'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.pie_chart_outline,
                    title: context.tr('analytics'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) =>
                              const DashboardScreen(initialIndex: 3),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),

                  const Divider(),
                  _SectionHeader(title: context.tr('finance')),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: context.tr('wallets'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.track_changes_outlined,
                    title: context.tr('budgets'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.flag_outlined,
                    title: context.tr('goals'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.category_outlined,
                    title: context.tr('categories'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),
                  _SectionHeader(title: context.tr('tools')),
                  _DrawerItem(
                    icon: Icons.auto_awesome,
                    title: 'RISHI AI',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AIChatScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_active_outlined,
                    title: context.tr('reminders'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReminderScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: context.tr('settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),
                  _SectionHeader(title: context.tr('legal_info')),
                  _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: context.tr('privacy_policy'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.gavel_outlined,
                    title: context.tr('terms_conditions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: context.tr('about_developer'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutDeveloperScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      return SwitchListTile(
                        title: Text(
                          context.tr('dark_mode'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        secondary: Icon(
                          settings.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: AppColors.primary,
                        ),
                        value: settings.themeMode == ThemeMode.dark,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          settings.setThemeMode(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Made with ❤️ by MITian RISHI',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
