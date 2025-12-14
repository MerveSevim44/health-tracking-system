// 📁 lib/screens/help_center_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Yardım Merkezi',
          style: theme.textTheme.headlineMedium?.copyWith(
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
                    theme.colorScheme.secondary.withOpacity(0.7),
                    theme.colorScheme.primary.withOpacity(0.7),
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
                    child: Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Size Nasıl Yardımcı Olabiliriz?',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sorularınızın cevaplarını burada bulabilirsiniz',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Sık Sorulan Sorular',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              context: context,
              question: 'Su takibini nasıl kullanırım?',
              answer:
                  'Su takibi özelliğini kullanmak için ana sayfadaki su ikonuna tıklayın. Su hedefinizi belirleyebilir, günlük su tüketiminizi kaydedebilir ve ilerlemenizi takip edebilirsiniz.',
            ),
            const SizedBox(height: 12),

            _buildFAQItem(
              context: context,
              question: 'İlaç hatırlatıcıları nasıl çalışır?',
              answer:
                  'İlaç hatırlatıcıları ayarlar bölümünden aktif edilebilir. İlaç ekledikten sonra, belirlediğiniz saatlerde size bildirim gönderilir.',
            ),
            const SizedBox(height: 12),

            _buildFAQItem(
              context: context,
              question: 'Ruh halimi nasıl kaydedebilirim?',
              answer:
                  'Ana sayfada bulunan + butonuna tıklayarak ruh halinizi seçebilir ve kaydedebilirsiniz. Günlük ruh hali kayıtlarınızı haftalık dashboard\'ta görebilirsiniz.',
            ),
            const SizedBox(height: 12),

            _buildFAQItem(
              context: context,
              question: 'Profil bilgilerimi nasıl düzenleyebilirim?',
              answer:
                  'Ayarlar sayfasından "Profili Düzenle" butonuna tıklayarak kullanıcı adı ve e-posta adresinizi değiştirebilirsiniz.',
            ),
            const SizedBox(height: 12),

            _buildFAQItem(
              context: context,
              question: 'Su hedefimi nasıl değiştiririm?',
              answer:
                  'Ayarlar sayfasında "Sağlık ve Hedefler" bölümünden "Su Hedefi" seçeneğine tıklayarak günlük su hedefinizi değiştirebilirsiniz.',
            ),
            const SizedBox(height: 32),

            // Contact Section
            Text(
              'İletişim',
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'E-posta',
                    subtitle: 'destek@healthtracking.com',
                    onTap: () {
                      // Email açma işlemi
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Telefon',
                    subtitle: '+90 (212) 555-0123',
                    onTap: () {
                      // Telefon açma işlemi
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    context: context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Canlı Destek',
                    subtitle: 'Hemen sohbet başlat',
                    onTap: () {
                      // Chat ekranına yönlendirme
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Support Hours
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destek Saatleri',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pazartesi - Cuma: 09:00 - 18:00\nCumartesi: 10:00 - 16:00',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.question_mark,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

