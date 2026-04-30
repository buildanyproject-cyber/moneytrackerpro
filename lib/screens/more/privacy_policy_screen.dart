import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4A42E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Last updated: March 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('1. Information We Collect'),
            _sectionBody(
              'MoneyTracker Pro collects and stores data locally on your device. '
              'We collect the following types of information:\n\n'
              '• Transaction data (income, expenses, amounts, dates)\n'
              '• Category and wallet information\n'
              '• Budget and goal settings\n'
              '• App preferences and settings\n\n'
              'All data is stored locally using Hive database and never transmitted '
              'to external servers without your explicit consent.',
            ),

            _sectionTitle('2. How We Use Your Information'),
            _sectionBody(
              'Your data is used solely to provide the core functionality of the app:\n\n'
              '• Track and manage your income and expenses\n'
              '• Generate financial reports and analytics\n'
              '• Provide budget alerts and reminders\n'
              '• Create backup and restore functionality\n'
              '• Display personalized financial insights',
            ),

            _sectionTitle('3. Data Storage & Security'),
            _sectionBody(
              'We prioritize the security of your data:\n\n'
              '• All data is stored locally on your device\n'
              '• PIN and biometric authentication protect app access\n'
              '• Google Drive backup is encrypted and requires your Google account authorization\n'
              '• We do not sell or share your personal financial data with third parties\n'
              '• Sensitive data like PIN codes are stored using Flutter Secure Storage',
            ),

            _sectionTitle('4. Google Drive Integration'),
            _sectionBody(
              'If you choose to use the Google Drive backup feature:\n\n'
              '• You will be asked to sign in with your Google account\n'
              '• Backup data is stored in your personal Google Drive\n'
              '• Only the MoneyTracker Pro app can access this backup folder\n'
              '• You can revoke access at any time from your Google account settings',
            ),

            _sectionTitle('5. Third-Party Services'),
            _sectionBody(
              'MoneyTracker Pro may use the following third-party services:\n\n'
              '• Google Sign-In (for Drive backup)\n'
              '• Google Drive API (for cloud backup/restore)\n'
              '• Local Notifications (for reminders)\n\n'
              'Each service has its own privacy policy that we encourage you to review.',
            ),

            _sectionTitle('6. Data Deletion'),
            _sectionBody(
              'You have full control over your data:\n\n'
              '• You can delete individual transactions, categories, or wallets anytime\n'
              '• The "Clear All Data" option in Settings removes all app data\n'
              '• Uninstalling the app will delete all locally stored data\n'
              '• Google Drive backups can be manually deleted from your Drive',
            ),

            _sectionTitle('7. Children\'s Privacy'),
            _sectionBody(
              'MoneyTracker Pro does not specifically target or collect data from '
              'children under 13. The app is designed for general use by individuals '
              'who want to manage their personal finances.',
            ),

            _sectionTitle('8. Changes to This Policy'),
            _sectionBody(
              'We may update this Privacy Policy from time to time. Any changes '
              'will be reflected in the app with an updated "Last modified" date. '
              'Continued use of the app after changes constitutes acceptance of '
              'the revised policy.',
            ),

            _sectionTitle('9. Contact Us'),
            _sectionBody(
              'If you have any questions or concerns about this Privacy Policy, '
              'please reach out to us:\n\n'
              '📧 Email: buildanyproject@gmail.com\n'
              '💻 GitHub: github.com/buildanyproject-cyber',
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 MoneyTracker Pro by MITian RISHI',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static Widget _sectionBody(String text) {
    return Text(text, style: const TextStyle(fontSize: 15, height: 1.6));
  }
}
