import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPrivacyScreen extends ConsumerStatefulWidget {
  final String initialTab; // 'terms' or 'privacy' or 'about'

  const TermsPrivacyScreen({super.key, this.initialTab = 'terms'});

  @override
  ConsumerState<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends ConsumerState<TermsPrivacyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final index = widget.initialTab == 'terms'
        ? 0
        : widget.initialTab == 'privacy'
        ? 1
        : 2;
    _tabController = TabController(length: 3, vsync: this, initialIndex: index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Terms'),
            Tab(text: 'Privacy'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsContent(),
          _buildPrivacyContent(),
          _buildAboutContent(),
        ],
      ),
    );
  }

  // ---------- Terms of Service ----------
  Widget _buildTermsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.gavel,
            title: 'Terms of Service',
            subtitle: 'Last updated: January 2024',
          ),
          const SizedBox(height: 20),

          _buildTermSection(
            title: '1. Acceptance of Terms',
            content:
                'By using BuilderConnect, you agree to these terms. If you don\'t agree, please don\'t use our service.',
          ),
          _buildTermSection(
            title: '2. User Accounts',
            content:
                'You must provide accurate information when creating an account. You\'re responsible for maintaining the security of your account.',
          ),
          _buildTermSection(
            title: '3. User Responsibilities',
            content:
                '• Provide accurate and truthful information\n'
                '• Respect other users\n'
                '• Don\'t misuse the platform\n'
                '• Comply with all applicable laws',
          ),
          _buildTermSection(
            title: '4. Artisan Responsibilities',
            content:
                'Artisans must accurately represent their skills and qualifications. Misrepresentation may result in account suspension.',
          ),
          _buildTermSection(
            title: '5. Customer Responsibilities',
            content:
                'Customers must treat artisans with respect. Provide clear instructions and communicate professionally.',
          ),
          _buildTermSection(
            title: '6. Intellectual Property',
            content:
                'All content on BuilderConnect is protected by copyright. You may not copy or reproduce without permission.',
          ),
          _buildTermSection(
            title: '7. Termination',
            content:
                'We reserve the right to suspend or terminate accounts that violate these terms or for any other reason.',
          ),
          _buildTermSection(
            title: '8. Disclaimer of Warranties',
            content:
                'BuilderConnect is provided "as is" without warranties of any kind. We don\'t guarantee the quality of services.',
          ),
          _buildTermSection(
            title: '9. Limitation of Liability',
            content:
                'BuilderConnect is not liable for any damages arising from use of the platform or services.',
          ),
          _buildTermSection(
            title: '10. Changes to Terms',
            content:
                'We may update these terms from time to time. Continued use constitutes acceptance of new terms.',
          ),
          _buildTermSection(
            title: '11. Contact',
            content:
                'For questions about these terms, contact us at:\nfranklinbright2025@gmail.com',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------- Privacy Policy ----------
  Widget _buildPrivacyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Last updated: January 2024',
          ),
          const SizedBox(height: 20),

          _buildTermSection(
            title: 'Information We Collect',
            content:
                'We collect information you provide when creating an account:\n'
                '• Name and contact information\n'
                '• Email address\n'
                '• Phone number\n'
                '• Profile photo\n'
                '• Location (if provided)',
          ),
          _buildTermSection(
            title: 'How We Use Your Information',
            content:
                'We use your information to:\n'
                '• Provide and improve our services\n'
                '• Connect customers with artisans\n'
                '• Send notifications and updates\n'
                '• Ensure platform security',
          ),
          _buildTermSection(
            title: 'Information Sharing',
            content:
                'We share information only when necessary:\n'
                '• With artisans (for customer inquiries)\n'
                '• With customers (for artisan services)\n'
                '• To comply with legal obligations',
          ),
          _buildTermSection(
            title: 'Data Security',
            content:
                'We implement industry-standard security measures to protect your data. However, no internet transmission is 100% secure.',
          ),
          _buildTermSection(
            title: 'Your Rights',
            content:
                'You have the right to:\n'
                '• Access your data\n'
                '• Correct inaccurate data\n'
                '• Delete your account\n'
                '• Opt out of communications',
          ),
          _buildTermSection(
            title: 'Cookies',
            content:
                'We use cookies to enhance your experience. You can disable cookies in your browser settings.',
          ),
          _buildTermSection(
            title: 'Third-Party Services',
            content:
                'We use Firebase for authentication and data storage. Their privacy policy applies to data processed by them.',
          ),
          _buildTermSection(
            title: 'Children\'s Privacy',
            content:
                'BuilderConnect is not intended for users under 13. We don\'t knowingly collect data from children.',
          ),
          _buildTermSection(
            title: 'Changes to Policy',
            content:
                'We may update this policy. Significant changes will be notified to users.',
          ),
          _buildTermSection(
            title: 'Contact Us',
            content:
                'For privacy concerns, contact:\nfranklinbright2025@gmail.com',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------- About Content ----------
  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // About Me Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.background,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bright Frank',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Founder & Developer',
                    style: TextStyle(fontSize: 14, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),

                // About description
                const Text(
                  'I\'m the creator of BuilderConnect, passionate about connecting people with trusted professionals. '
                  'I believe in making it easy to find quality service providers, because everyone deserves to find '
                  'the right person for the job.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Contact items
                _buildContactItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: 'franklinbright2025@gmail.com',
                  onTap: () => _launchEmail('franklinbright2025@gmail.com'),
                ),
                const SizedBox(height: 8),
                _buildContactItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: '+234 906 146 4373',
                  onTap: () => _launchPhone('+2349061464373'),
                ),
                const SizedBox(height: 8),
                _buildContactItem(
                  icon: Icons.language,
                  label: 'Website',
                  value: 'builderconnect.com',
                  onTap: () => _launchUrl('https://builderconnect.com'),
                ),
                const SizedBox(height: 8),
                _buildContactItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: 'Nigeria',
                  onTap: null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Social Links
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Connect with Me',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.email,
                      color: Colors.red,
                      onTap: () => _launchEmail('franklinbright2025@gmail.com'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.code,
                      color: AppColors.primary,
                      onTap: () => _launchUrl('https://github.com/BrightFK'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      icon: Icons.link,
                      color: AppColors.secondary,
                      onTap: () =>
                          _launchUrl('https://linkedin.com/in/brightfrank'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Version info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'BuilderConnect v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ in Nigeria',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------- Helper Widgets ----------
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // ---------- Launch Methods ----------
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=BuilderConnect Inquiry',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        context.showSnackBar('Please email us at $email');
      }
    } catch (e) {
      context.showSnackBar('Could not open email app');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        context.showSnackBar('Could not make call');
      }
    } catch (e) {
      context.showSnackBar('Could not make call');
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        context.showSnackBar('Could not open link');
      }
    } catch (e) {
      context.showSnackBar('Could not open link');
    }
  }
}
