import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
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
                  colors: [Color(0xFF4A42E8), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.gavel, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Effective Date: March 2026',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('1. Acceptance of Terms'),
            _sectionBody(
              'By downloading, installing, or using MoneyTracker Pro ("the App"), '
              'you agree to be bound by these Terms and Conditions. If you do not '
              'agree to these terms, please do not use the App.',
            ),

            _sectionTitle('2. Description of Service'),
            _sectionBody(
              'MoneyTracker Pro is a personal finance management application that allows users to:\n\n'
              '• Track income and expenses\n'
              '• Set and manage budgets\n'
              '• Create savings goals\n'
              '• Generate financial reports and analytics\n'
              '• Backup/restore data via Google Drive\n'
              '• Export reports as PDF and CSV\n'
              '• Manage multiple wallets and categories',
            ),

            _sectionTitle('3. User Responsibilities'),
            _sectionBody(
              'As a user, you agree to:\n\n'
              '• Provide accurate financial data for your own records\n'
              '• Maintain the security of your device and app access (PIN/biometric)\n'
              '• Use the App for lawful personal finance tracking purposes only\n'
              '• Not attempt to reverse-engineer, decompile, or exploit the App\n'
              '• Keep your Google account credentials secure if using Drive backup',
            ),

            _sectionTitle('4. Data Accuracy'),
            _sectionBody(
              'MoneyTracker Pro provides tools for personal financial tracking. '
              'We do not guarantee the accuracy of any financial calculations or reports. '
              'The App should not be used as a substitute for professional financial advice. '
              'Users are responsible for verifying the accuracy of their data entries.',
            ),

            _sectionTitle('5. Intellectual Property'),
            _sectionBody(
              'All content, features, and functionality of MoneyTracker Pro, including '
              'but not limited to text, graphics, logos, icons, images, and software, '
              'are the property of the developer (MITian RISHI) and are protected by '
              'applicable intellectual property laws.',
            ),

            _sectionTitle('6. Limitation of Liability'),
            _sectionBody(
              'To the maximum extent permitted by law:\n\n'
              '• The App is provided "AS IS" without warranties of any kind\n'
              '• We are not liable for any data loss, financial loss, or damages '
              'arising from the use of the App\n'
              '• We are not responsible for any unauthorized access to your device or data\n'
              '• We do not guarantee uninterrupted or error-free operation of the App',
            ),

            _sectionTitle('7. Google Drive Backup'),
            _sectionBody(
              'The Google Drive backup feature is provided as a convenience:\n\n'
              '• We are not responsible for data stored on Google Drive\n'
              '• Google\'s Terms of Service apply to data stored on their platform\n'
              '• Users are responsible for maintaining their Google account access\n'
              '• Backup success depends on internet connectivity and Google service availability',
            ),

            _sectionTitle('8. Updates & Modifications'),
            _sectionBody(
              'We reserve the right to:\n\n'
              '• Update, modify, or discontinue any feature of the App\n'
              '• Change these Terms & Conditions at any time\n'
              '• Release new versions of the App with updated functionality\n\n'
              'Continued use after changes constitutes acceptance of the modified terms.',
            ),

            _sectionTitle('9. Termination'),
            _sectionBody(
              'You may stop using the App at any time by uninstalling it. '
              'Upon uninstallation, all locally stored data will be permanently deleted. '
              'Data backed up to Google Drive will remain until manually deleted.',
            ),

            _sectionTitle('10. Governing Law'),
            _sectionBody(
              'These Terms & Conditions are governed by and construed in accordance '
              'with the laws of India. Any disputes arising from or relating to these '
              'terms shall be subject to the exclusive jurisdiction of courts in India.',
            ),

            _sectionTitle('11. Contact Information'),
            _sectionBody(
              'For any questions about these Terms & Conditions, contact us:\n\n'
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
