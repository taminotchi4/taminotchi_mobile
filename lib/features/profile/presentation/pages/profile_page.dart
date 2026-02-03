import 'package:flutter/material.dart';

import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/common_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Profil'),
      body: Center(
        child: Text(
          'Profil ma\'lumotlari',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
