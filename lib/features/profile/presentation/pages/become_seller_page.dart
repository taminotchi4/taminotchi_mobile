import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';

class BecomeSellerPage extends StatelessWidget {
  const BecomeSellerPage({super.key});

  static const _androidUrl =
      'https://play.google.com/store/apps/details?id=com.taminotchi.seller';
  static const _iosUrl =
      'https://apps.apple.com/app/taminotchi-seller/id0000000000';

  Future<void> _openStore(BuildContext context) async {
    final url = Platform.isIOS ? _iosUrl : _androidUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Havola ochilmadi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = Platform.isIOS;

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Sotuvchi bo\'lish',
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner
            Container(
              height: 240.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern circles
                  Positioned(
                    right: -30.r,
                    top: -30.r,
                    child: Container(
                      width: 180.r,
                      height: 180.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20.r,
                    bottom: -20.r,
                    child: Container(
                      width: 140.r,
                      height: 140.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 38.r,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Taminotchi Seller',
                          style: AppStyles.h3Bold.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Biznesingizni onlayn olib boring',
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppDimens.lg.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Benefits section
                  Text(
                    'Sotuvchi bo\'lishning afzalliklari',
                    style: AppStyles.h4Bold.copyWith(
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  _BenefitCard(
                    icon: Icons.people_alt_outlined,
                    color: const Color(0xFF4CAF50),
                    title: 'Millionlab xaridorlarga yeting',
                    description:
                        'Taminotchi platformasidagi faol xaridorlarga mahsulot va xizmatlaringizni taqdim eting.',
                  ),
                  SizedBox(height: 12.h),
                  _BenefitCard(
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF2196F3),
                    title: 'Savdoni oshiring',
                    description:
                        'Real-time bildirishnomalar, chat va statistika orqali savdoni monitoring qiling.',
                  ),
                  SizedBox(height: 12.h),
                  _BenefitCard(
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFFFF9800),
                    title: 'O\'z do\'koningizni yarating',
                    description:
                        'Mahsulot va xizmatlaringizni toifalarga ajratib, chiroyli do\'kon sahifasi bilan taqdim eting.',
                  ),
                  SizedBox(height: 12.h),
                  _BenefitCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF9C27B0),
                    title: 'Xaridorlar bilan bevosita muloqot',
                    description:
                        'Real-time chat orqali xaridorlar savollariga tezkor javob bering.',
                  ),
                  SizedBox(height: 12.h),
                  _BenefitCard(
                    icon: Icons.security_rounded,
                    color: const Color(0xFF009688),
                    title: 'Xavfsiz va ishonchli',
                    description:
                        'To\'lovlar va ma\'lumotlaringiz to\'liq himoyalangan platformada ishlang.',
                  ),

                  SizedBox(height: 28.h),

                  // Requirements section
                  Text(
                    'Talablar',
                    style: AppStyles.h4Bold.copyWith(
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _RequirementItem('Raqobatbardosh mahsulot yoki xizmat'),
                  _RequirementItem('Faol telefon raqami'),
                  _RequirementItem('Taminotchi Seller ilovasini yuklab olish'),
                  _RequirementItem('Bir martalik ro\'yxatdan o\'tish (bepul)'),

                  SizedBox(height: 32.h),

                  // Download button
                  _DownloadButton(
                    isIOS: isIOS,
                    onTap: () => _openStore(context),
                  ),

                  SizedBox(height: 16.h),

                  // Note
                  Center(
                    child: Text(
                      isIOS
                          ? 'App Store orqali yuklab oling'
                          : 'Play Market orqali yuklab oling',
                      style: AppStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Benefit Card ---
class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: AppDimens.borderWidth.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 22.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Requirement Item ---
class _RequirementItem extends StatelessWidget {
  final String text;
  const _RequirementItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).primaryColor,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Download Button ---
class _DownloadButton extends StatelessWidget {
  final bool isIOS;
  final VoidCallback onTap;

  const _DownloadButton({required this.isIOS, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isIOS ? Icons.apple_rounded : Icons.android_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: 20.r,
            ),
            SizedBox(width: 10.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIOS ? 'App Store\'dan yuklab oling' : 'Play Market\'dan yuklab oling',
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'Taminotchi Seller',
                  style: AppStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
