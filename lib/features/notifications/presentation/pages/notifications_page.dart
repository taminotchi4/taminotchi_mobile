import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taminotchi_app/core/utils/extensions.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../../features/chat/presentation/managers/notification_proxy_bloc.dart';
import '../managers/notification_bloc.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.notifications,
        leading: const AppBackButton(),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationProxyBloc>().markAllRead(),
            child: Text(
              'Barchasini o\'qildi',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationProxyBloc, NotificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return Center(
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
                    context.l10n.notificationsNone,
                    style: AppStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.notifications.length,
            padding: EdgeInsets.only(bottom: AppDimens.lg.h),
            itemBuilder: (context, index) {
              final notif = state.notifications[index];
              final timeStr = _formatTime(notif.createdAt);

              return NotificationItem(
                title: _getTitle(notif.type),
                message: notif.preview ?? '',
                time: timeStr,
                isUnread: !notif.isRead,
                onTap: () {
                  // Mark as read
                  if (!notif.isRead) {
                    context.read<NotificationProxyBloc>().markRead(notif.id);
                  }
                  // Navigate
                  if (notif.referenceType == 'private_chat' && notif.referenceId != null) {
                    context.push(Routes.getPrivateChat(notif.referenceId!));
                  } else if (notif.referenceType == 'group' && notif.referenceId != null) {
                    context.push(Routes.getGroupChat(notif.referenceId!));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case 'new_message':
        return 'Yangi xabar';
      case 'elon_comment':
        return 'Guruhingizda yangi elon';
      default:
        return 'Bildirishnoma';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays == 1) return 'Kecha';
    return DateFormat('dd.MM.yyyy').format(dt);
  }
}
