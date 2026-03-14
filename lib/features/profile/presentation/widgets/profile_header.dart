import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/client_profile_entity.dart';
import '../pages/edit_profile_page.dart';
import '../../../../core/utils/extensions.dart';

class ProfileHeader extends StatelessWidget {
  final ClientProfileEntity profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDimens.lg.height,
        Container(
          width: 120.r,
          height: 120.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
            style: AppStyles.h1Bold.copyWith(
              color: Colors.white,
              fontSize: 48.sp,
            ),
          ),
        ),
        AppDimens.lg.height,
        Text(
          profile.name,
          style: AppStyles.h3Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        AppDimens.xs.height,
        Text(
          profile.username,
          style: AppStyles.bodyMedium.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        AppDimens.sm.height,
        Text(
          profile.phone,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        AppDimens.xl.height,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profile: profile),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Profilni tahrirlash',
              style: AppStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
