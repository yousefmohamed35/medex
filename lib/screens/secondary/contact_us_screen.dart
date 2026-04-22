import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_text_styles.dart';
import '../../core/design/app_radius.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isAr ? 'تواصل معنا' : 'Contact Us',
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
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.lavenderLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/medex_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.medical_services_rounded,
                                    size: 36,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isAr ? 'تواصل مع ميدكس' : 'Contact Medex',
                              style: AppTextStyles.h3(color: AppColors.foreground),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isAr
                                  ? 'رواد طب الأسنان في مصر والشرق الأوسط وأفريقيا'
                                  : 'Leading dental solutions in Egypt, Middle East & Africa',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedForeground, height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        context: context,
                        icon: Icons.email_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.lavenderLight,
                        title: isAr ? 'البريد الإلكتروني' : 'Email',
                        subtitle: 'info@medex-med.com',
                        actionLabel: isAr ? 'إرسال بريد إلكتروني' : 'Send Email',
                        onAction: () => _sendEmail(),
                        onCopy: () {
                          Clipboard.setData(const ClipboardData(text: 'info@medex-med.com'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAr ? 'تم نسخ البريد الإلكتروني' : 'Email copied', style: GoogleFonts.cairo()),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        context: context,
                        icon: Icons.phone_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFD1FAE5),
                        title: isAr ? 'رقم الهاتف' : 'Phone',
                        subtitle: '01287333308',
                        actionLabel: isAr ? 'اتصل الآن' : 'Call Now',
                        onAction: () => _callPhone(),
                        onCopy: () {
                          Clipboard.setData(const ClipboardData(text: '01287333308'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAr ? 'تم نسخ رقم الهاتف' : 'Phone number copied', style: GoogleFonts.cairo()),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        context: context,
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        iconBgColor: const Color(0xFFDBEAFE),
                        title: isAr ? 'العنوان' : 'Address',
                        subtitle: isAr
                            ? '157 شارع السودان، الدور الثاني - الجيزة - مصر'
                            : '157 Sudan Street, Second Floor - Giza - Egypt',
                        actionLabel: isAr ? 'عرض على الخريطة' : 'View on Map',
                        onAction: () => _openMap(),
                      ),
                      const SizedBox(height: 16),
                      _buildContactCard(
                        context: context,
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBgColor: const Color(0xFFEDE9FE),
                        title: isAr ? 'الموقع الإلكتروني' : 'Website',
                        subtitle: 'medex-med.com',
                        actionLabel: isAr ? 'زيارة الموقع' : 'Visit Website',
                        onAction: () => _openUrl('https://medex-med.com'),
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

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    VoidCallback? onCopy,
  }) {
    return Container(
      width: double.infinity,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.mutedForeground)),
                    Text(subtitle, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  ],
                ),
              ),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.mutedForeground),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [iconColor.withOpacity(0.1), iconColor.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: iconColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Text(actionLabel, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'info@medex-med.com');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _callPhone() async {
    final uri = Uri(scheme: 'tel', path: '01287333308');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMap() async {
    final uri = Uri.parse('https://maps.google.com/?q=157+Sudan+Street+Giza+Egypt');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
