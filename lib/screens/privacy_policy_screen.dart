// 📁 lib/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gizlilik Politikası',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.pastelLavender,
                    AppColors.pastelMint,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.moodCalm,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gizliliğiniz Bizim İçin Önemli',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Son güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Privacy Policy Content
            _buildSection(
              title: '1. Veri Toplama',
              content:
                  'Health Tracking uygulaması, size en iyi hizmeti sunabilmek için aşağıdaki verileri toplar:\n\n'
                  '• Kullanıcı adı ve e-posta adresi\n'
                  '• Su tüketim kayıtları\n'
                  '• İlaç kullanım bilgileri\n'
                  '• Ruh hali kayıtları\n'
                  '• Sağlık hedefleri ve tercihleri',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '2. Veri Kullanımı',
              content:
                  'Topladığımız veriler aşağıdaki amaçlar için kullanılır:\n\n'
                  '• Sağlık takip özelliklerinin sağlanması\n'
                  '• Kişiselleştirilmiş öneriler sunulması\n'
                  '• Uygulamanın iyileştirilmesi\n'
                  '• Kullanıcı deneyiminin geliştirilmesi\n'
                  '• İletişim ve destek hizmetleri',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '3. Veri Güvenliği',
              content:
                  'Verilerinizin güvenliği bizim için çok önemlidir. Tüm verileriniz şifreli bağlantılar üzerinden (HTTPS) iletilir ve güvenli sunucularda saklanır. '
                  'Firebase güvenlik standartlarına uygun olarak verileriniz korunmaktadır.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '4. Veri Paylaşımı',
              content:
                  'Kişisel verilerinizi üçüncü taraflarla paylaşmıyoruz. Verileriniz yalnızca:\n\n'
                  '• Sizin açık izninizle\n'
                  '• Yasal zorunluluklar gereği\n'
                  '• Uygulama hizmetlerinin sağlanması için gerekli durumlarda paylaşılabilir.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '5. Veri Saklama',
              content:
                  'Hesabınız aktif olduğu sürece verileriniz saklanır. Hesabınızı sildiğinizde, tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '6. Haklarınız',
              content:
                  'KVKK kapsamında aşağıdaki haklara sahipsiniz:\n\n'
                  '• Kişisel verilerinizin işlenip işlenmediğini öğrenme\n'
                  '• Kişisel verilerinize erişim talep etme\n'
                  '• Verilerinizin düzeltilmesini isteme\n'
                  '• Verilerinizin silinmesini talep etme\n'
                  '• Verilerinizin işlenmesine itiraz etme\n'
                  '• Verilerinizin taşınabilirliğini isteme',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '7. Çerezler',
              content:
                  'Uygulamamız, kullanıcı deneyimini iyileştirmek için çerezler kullanabilir. Çerezler, kullanıcı tercihlerini hatırlamak ve uygulamanın daha iyi çalışmasını sağlamak için kullanılır.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '8. Değişiklikler',
              content:
                  'Gizlilik politikamızı zaman zaman güncelleyebiliriz. Önemli değişiklikler yapıldığında, size bildirimde bulunacağız. '
                  'Bu sayfayı düzenli olarak kontrol etmenizi öneririz.',
            ),
            const SizedBox(height: 24),

            // Contact Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pastelBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.moodCalm.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.moodCalm,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'İletişim',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gizlilik politikası ile ilgili sorularınız için bizimle iletişime geçebilirsiniz:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'E-posta: gizlilik@healthtracking.com',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.moodCalm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

