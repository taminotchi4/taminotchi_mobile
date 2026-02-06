import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/common_app_bar.dart';

class ChatsHomePage extends StatelessWidget {
  const ChatsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'sellerId': 'seller_1',
        'name': 'Tech Store',
        'lastMessage': 'Mahsulot haqida ma\'lumot',
        'unreadCount': 2,
        'time': '10:30',
        'role': 'Market',
      },
      {
        'sellerId': 'seller_2',
        'name': 'Fashion Shop',
        'lastMessage': 'Buyurtma qabul qilindi',
        'unreadCount': 0,
        'time': 'Kecha',
        'role': 'Market',
      },
      {
        'sellerId': 'seller_3',
        'name': 'Ali Valiyev',
        'lastMessage': 'Yetkazib berish haqida',
        'unreadCount': 1,
        'time': '15:45',
        'role': 'User',
      },
    ];

    return Scaffold(
      appBar: const CommonAppBar(title: 'Chatlar'),
      body: chats.isEmpty
          ? Center(
              child: Text(
                'Chatlar yo\'q',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(AppDimens.lg.r),
              itemCount: chats.length,
              separatorBuilder: (context, index) => AppDimens.md.height,
              itemBuilder: (context, index) {
                final chat = chats[index];
                  return _ChatItem(
                    sellerId: chat['sellerId'] as String,
                    name: chat['name'] as String,
                    lastMessage: chat['lastMessage'] as String,
                    unreadCount: chat['unreadCount'] as int,
                    time: chat['time'] as String,
                    role: chat['role'] as String,
                  );
              },
            ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String sellerId;
  final String name;
  final String lastMessage;
  final int unreadCount;
  final String time;
  final String role;

  const _ChatItem({
    required this.sellerId,
    required this.name,
    required this.lastMessage,
    required this.unreadCount,
    required this.time,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        Routes.getSellerChat(sellerId),
        extra: {'name': name, 'role': role},
      ),
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppStyles.h4Bold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            AppDimens.md.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                            AppDimens.xs.width,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: role == 'Market'
                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                    : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                role,
                                style: AppStyles.bodySmall.copyWith(
                                  fontSize: 10.sp,
                                  color: role == 'Market'
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        time,
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 11.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  AppDimens.xs.height,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        AppDimens.sm.width,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: AppStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
