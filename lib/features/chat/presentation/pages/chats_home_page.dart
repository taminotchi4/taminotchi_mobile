import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../data/models/private_chat_model.dart';
import '../managers/private_chat_list_bloc.dart';

class ChatsHomePage extends StatefulWidget {
  const ChatsHomePage({super.key});

  @override
  State<ChatsHomePage> createState() => _ChatsHomePageState();
}

class _ChatsHomePageState extends State<ChatsHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PrivateChatListBloc>().add(PrivateChatListLoad());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(title: context.l10n.chats),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.lg.w,
                AppDimens.sm.h,
                AppDimens.lg.w,
                AppDimens.sm.h,
              ),
              child: SizedBox(
                height: 40.h,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: AppStyles.bodySmall.copyWith(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.search,
                    hintStyle: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: 13.sp,
                    ),
                    prefixIcon: Icon(Icons.search, size: 18.r),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18.r),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PrivateChatListBloc, PrivateChatListState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final chats = state.chats.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    final peerName = _getPeerName(c).toLowerCase();
                    final preview = c.lastMessage?.text?.toLowerCase() ?? '';
                    return peerName.contains(q) || preview.contains(q);
                  }).toList();

                  if (chats.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? context.l10n.noChats : context.l10n.resultNotFound,
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollStartNotification) FocusScope.of(context).unfocus();
                      return false;
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(AppDimens.lg.r),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => AppDimens.md.height,
                      itemBuilder: (context, index) {
                        return _ChatItem(chat: chats[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeerName(PrivateChatModel chat) {
    final market = chat.market;
    if (market is Map) return market['name'] as String? ?? 'Market';
    return 'Chat';
  }
}

class _ChatItem extends StatelessWidget {
  final PrivateChatModel chat;

  const _ChatItem({required this.chat});

  String get _peerName {
    final market = chat.market;
    if (market is Map) return market['name'] as String? ?? 'Market';
    return 'Market';
  }

  @override
  Widget build(BuildContext context) {
    final lastMsg = chat.lastMessage;
    final timeStr = lastMsg != null
        ? DateFormat('HH:mm').format(lastMsg.createdAt.toLocal())
        : '';

    return InkWell(
      onTap: () {
        context.read<PrivateChatListBloc>().add(PrivateChatListMarkRead(chat.id));
        context.push(
          Routes.getPrivateChat(chat.id),
          extra: {'name': _peerName},
        );
      },
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
                _peerName.isNotEmpty ? _peerName[0].toUpperCase() : '?',
                style: AppStyles.h4Bold.copyWith(color: Colors.white),
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
                        child: Text(
                          _peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
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
                          lastMsg?.text ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
