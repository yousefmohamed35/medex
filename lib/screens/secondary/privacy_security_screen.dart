import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_text_styles.dart';
import '../../core/design/app_radius.dart';
import '../../core/config/app_config_provider.dart';
import '../../l10n/app_localizations.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final config = AppConfigProvider().config;
    final privacyUrl = config?.legal.privacyUrl ?? '';
    final termsUrl = config?.legal.termsUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD42535), Color(0xFFB01E2D)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.largeCard),
                  bottomRight: Radius.circular(AppRadius.largeCard),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.whiteOverlay20,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n.privacyAndSecurity,
                    style: AppTextStyles.h3(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        icon: Icons.shield_rounded,
                        title: isAr ? 'حماية البيانات' : 'Data Protection',
                        content: isAr
                            ? 'نحن نأخذ حماية بياناتك على محمل الجد. يتم تشفير جميع البيانات الشخصية وتخزينها بشكل آمن على خوادمنا. لا نشارك بياناتك مع أطراف ثالثة دون موافقتك.'
                            : 'We take your data protection seriously. All personal data is encrypted and securely stored on our servers. We do not share your data with third parties without your consent.',
                      ),
                      _buildSection(
                        icon: Icons.lock_rounded,
                        title: isAr ? 'أمان الحساب' : 'Account Security',
                        content: isAr
                            ? 'حسابك محمي بكلمة مرور مشفرة. ننصحك باستخدام كلمة مرور قوية وعدم مشاركتها مع أي شخص. يمكنك تغيير كلمة المرور في أي وقت من الإعدادات.'
                            : 'Your account is protected with an encrypted password. We recommend using a strong password and not sharing it with anyone. You can change your password at any time from settings.',
                      ),
                      _buildSection(
                        icon: Icons.smartphone_rounded,
                        title: isAr ? 'لقطات الشاشة والتسجيل' : 'Screenshots & recording',
                        content: isAr
                            ? 'يمكنك التقاط لقطات شاشة أو تسجيل الشاشة حسب إعدادات جهازك. ننصح بعدم مشاركة محتوى الدروس أو بيانات حساسة مع أشخاص غير مخولين.'
                            : 'You may take screenshots or record the screen according to your device settings. Please avoid sharing lesson content or sensitive data with unauthorized parties.',
                      ),
                      _buildSection(
                        icon: Icons.storage_rounded,
                        title: isAr ? 'البيانات المحفوظة' : 'Stored Data',
                        content: isAr
                            ? 'نحتفظ ببيانات حسابك ومعلومات التقدم التعليمي والتفضيلات فقط. يمكنك طلب حذف حسابك وجميع البيانات المرتبطة به في أي وقت.'
                            : 'We only retain your account data, educational progress, and preferences. You can request deletion of your account and all associated data at any time.',
                      ),
                      _buildSection(
                        icon: Icons.notifications_rounded,
                        title: isAr ? 'الإشعارات' : 'Notifications',
                        content: isAr
                            ? 'نرسل إشعارات حول تحديثات الكورسات والامتحانات والأحداث الجديدة فقط. يمكنك التحكم في إعدادات الإشعارات من صفحة الإعدادات.'
                            : 'We only send notifications about course updates, exams, and new events. You can control notification settings from the settings page.',
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.lavenderLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.description_rounded, size: 20, color: AppColors.purple),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isAr ? 'روابط مهمة' : 'Important Links',
                                  style: AppTextStyles.h4(color: AppColors.foreground),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildLinkTile(
                              icon: Icons.privacy_tip_rounded,
                              title: isAr ? 'سياسة الخصوصية والشروط والأحكام' : 'Privacy Policy & Terms',
                              onTap: () => _openUrl('https://medex-med.com/privacy-policy'),
                            ),
                            if (privacyUrl.isNotEmpty && privacyUrl != 'https://medex-med.com/privacy-policy') ...[
                              const SizedBox(height: 8),
                              _buildLinkTile(
                                icon: Icons.policy_rounded,
                                title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                                onTap: () => _openUrl(privacyUrl),
                              ),
                            ],
                            if (termsUrl.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildLinkTile(
                                icon: Icons.gavel_rounded,
                                title: isAr ? 'الشروط والأحكام' : 'Terms & Conditions',
                                onTap: () => _openUrl(termsUrl),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lavenderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h4(color: AppColors.foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.mutedForeground,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.purple, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: AppColors.mutedForeground, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
