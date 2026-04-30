import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Connect With Me', isDark)
                      .animate()
                      .fade(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.05, end: 0),
                  const SizedBox(height: 16),
                  _buildSocialLinks(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 300.ms)
                      .scaleXY(begin: 0.9, end: 1.0),
                  const SizedBox(height: 32),
                  _buildAboutDeveloperCard(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  _buildAboutAppCard(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  _buildTechStackGrid(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  _buildPrivacyCommitmentCard(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 700.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  _buildAppInfoCard(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 800.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  _buildRateAppCard(isDark)
                      .animate()
                      .fade(duration: 500.ms, delay: 900.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Hero Section
  Widget _buildHeroSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: const Icon(
                Icons.person_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            'Rishikesh Kumar',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 6),
          Text(
            'Founder & Developer',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 1.2,
            ),
          ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '"Building intelligent tools for developers\nand everyday users."',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ).animate().fade(delay: 400.ms).scaleXY(begin: 0.9, end: 1),
        ],
      ),
    );
  }

  // Section Title Helper
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }

  // 6. Social Links Row
  Widget _buildSocialLinks(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SocialBtn(
          icon: FontAwesomeIcons.linkedinIn,
          color: const Color(0xFF0077b5),
          url: 'https://www.linkedin.com/in/royalrishi',
          isDark: isDark,
        ),
        _SocialBtn(
          icon: FontAwesomeIcons.github,
          color: isDark ? Colors.white : Colors.black,
          url: 'https://github.com/buildanyproject-cyber',
          isDark: isDark,
        ),
        _SocialBtn(
          icon: FontAwesomeIcons.instagram,
          color: const Color(0xFFE1306C),
          url: 'https://instagram.com/logic_overloading',
          isDark: isDark,
        ),
        _SocialBtn(
          icon: FontAwesomeIcons.envelope,
          color: const Color(0xFFEA4335),
          url: 'mailto:buildanyproject@gmail.com',
          isDark: isDark,
        ),
        _SocialBtn(
          icon: FontAwesomeIcons.globe,
          color: AppColors.primary,
          url: 'https://royallogix.digital',
          isDark: isDark,
        ),
      ],
    );
  }

  // 2. About Developer Card
  Widget _buildAboutDeveloperCard(bool isDark) {
    return _InfoCard(
      isDark: isDark,
      title: 'About Me',
      icon: Icons.person_search_rounded,
      iconColor: AppColors.primary,
      content: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          children: const [
            TextSpan(
              text:
                  'I am a software developer passionate about building intelligent applications and developer tools. My focus is on creating practical digital products including ',
            ),
            TextSpan(
              text: 'fintech apps, AI tools, and productivity software',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  '.\n\nMoneyTracker Pro was built with a commitment to help users take control of their personal finances through secure and privacy-focused technology.',
            ),
          ],
        ),
      ),
    );
  }

  // 3. About the App Card
  Widget _buildAboutAppCard(bool isDark) {
    return _InfoCard(
      isDark: isDark,
      title: 'Why MoneyTracker Pro?',
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Colors.amber,
      content: Column(
        children: [
          _FeatureRow(
            icon: Icons.wifi_off_rounded,
            title: 'Offline-first architecture',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.lock_outline_rounded,
            title: 'Secure local data storage',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.analytics_outlined,
            title: 'Smart spending analytics',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.track_changes_rounded,
            title: 'Budget and financial insights',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // 4. Technology Stack
  Widget _buildTechStackGrid(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Technologies Used', isDark),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _TechChip(
              icon: FlutterLogo(size: 18),
              label: 'Flutter 3',
              isDark: isDark,
            ),
            _TechChip(
              icon: Icon(Icons.storage, size: 18, color: Colors.orange),
              label: 'Hive DB',
              isDark: isDark,
            ),
            _TechChip(
              icon: Icon(Icons.color_lens, size: 18, color: Colors.pink),
              label: 'Material 3',
              isDark: isDark,
            ),
            _TechChip(
              icon: Icon(Icons.cloud_upload, size: 18, color: Colors.blue),
              label: 'Drive Backup',
              isDark: isDark,
            ),
            _TechChip(
              icon: Icon(
                Icons.notifications_active,
                size: 18,
                color: Colors.amber,
              ),
              label: 'Local Notif.',
              isDark: isDark,
            ),
            _TechChip(
              icon: Icon(Icons.fingerprint, size: 18, color: Colors.teal),
              label: 'Biometrics',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // 5. Privacy Commitment
  Widget _buildPrivacyCommitmentCard(bool isDark) {
    return _InfoCard(
      isDark: isDark,
      title: 'Privacy Commitment',
      icon: Icons.shield_outlined,
      iconColor: AppColors.income,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finance apps require absolute trust. Here is how your data is protected:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.check_circle_rounded,
            title: 'All financial data stored locally',
            color: AppColors.income,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            icon: Icons.check_circle_rounded,
            title: 'No data sent to external servers',
            color: AppColors.income,
          ),
          const SizedBox(height: 8),
          _FeatureRow(
            icon: Icons.check_circle_rounded,
            title: 'Optional user-controlled Drive backup',
            color: AppColors.income,
          ),
        ],
      ),
    );
  }

  // 7. App Information
  Widget _buildAppInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'App Name',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                AppConstants.appName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const Text(
                '1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const Text(
                'Personal Finance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. Rate App Section & Support
  Widget _buildRateAppCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 48),
          const SizedBox(height: 16),
          Text(
            'Enjoying MoneyTracker Pro?',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Support the project by rating the app on the Play Store or reach out with feedback!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Rating action
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Rate App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'buildanyproject@gmail.com',
                      query: 'subject=MoneyTracker Pro Feedback',
                    );
                    launchUrl(emailLaunchUri);
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Feedback'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Feature Row Widget
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// Reusable Tech Chip Widget
class _TechChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isDark;

  const _TechChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Social Button Widget
class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String url;
  final bool isDark;

  const _SocialBtn({
    required this.icon,
    required this.color,
    required this.url,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            final uri = Uri.parse(url);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FaIcon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}

// Reusable Info Card Widget
class _InfoCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;

  const _InfoCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}
