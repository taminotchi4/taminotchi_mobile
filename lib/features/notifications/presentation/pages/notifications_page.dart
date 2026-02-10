import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taminotchi_app/core/utils/extensions.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for notifications
    final notifications = [
      {
        'title': 'Yangi buyurtma',
        'message': 'Sizning #1234 raqamli buyurtmangiz qabul qilindi.',
        'time': 'Hozirgina',
        'isUnread': true,
      },
      {
        'title': 'Chegirma!',
        'message': 'Barcha qurilish mollari uchun 20% chegirma.',
        'time': '1 soat oldin',
        'isUnread': true,
      },
      {
        'title': 'Tizim xabari',
        'message': 'Ilovada texnik ishlar yakunlandi. Endi u yanada tezroq!',
        'time': 'Kecha',
        'isUnread': false,
      },
       {
        'title': 'To\'lov tasdiqlandi',
        'message': 'Sizning to\'lovingiz muvaffaqiyatli amalga oshirildi.',
        'time': '2 kun oldin',
        'isUnread': false,
      },
    ];

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Bildirishnomalar',
        leading: AppBackButton(),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64.r,
                    color: Theme.of(context).disabledColor,
                  ),
                  AppDimens.md.height,
                  Text(
                    'Bildirishnomalar yo\'q',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              padding: EdgeInsets.only(bottom: AppDimens.lg.h),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification['title'].toString() + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: AppDimens.lg.w),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                  onDismissed: (direction) {
                    // TODO: Implement delete logic
                  },
                  child: NotificationItem(
                    title: notification['title'] as String,
                    message: notification['message'] as String,
                    time: notification['time'] as String,
                    isUnread: notification['isUnread'] as bool,
                    onTap: () {
                      // TODO: Implement navigation or mark as read
                    },
                  ),
                );
              },
            ),
    );
  }
}
