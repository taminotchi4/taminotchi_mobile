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
import '../../data/models/market_model.dart';
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
    return BlocListener<PrivateChatListBloc, PrivateChatListState>(
      listenWhen: (prev, curr) => curr.navigateTo != null && curr.navigateTo != prev.navigateTo,
      listener: (context, state) {
        final nav = state.navigateTo!;
        // Reset navigateTo so it won't trigger again on rebuild
        context.read<PrivateChatListBloc>().add(PrivateChatListClearSearch());
        context.push(
          Routes.getPrivateChat(nav.chatId),
          extra: {
            'chatId': nav.chatId,
            'name': nav.name,
            'receiverId': nav.receiverId,
            'receiverRole': nav.receiverRole,
          },
        );
      },
      child: GestureDetector(
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
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    if (value.isEmpty) {
                      context
                          .read<PrivateChatListBloc>()
                          .add(PrivateChatListClearSearch());
                    } else {
                      context
                          .read<PrivateChatListBloc>()
                          .add(PrivateChatListSearch(value));
                    }
                  },
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
                              context
                                  .read<PrivateChatListBloc>()
                                  .add(PrivateChatListClearSearch());
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PrivateChatListBloc, PrivateChatListState>(
                builder: (context, state) {
                  if (state.isLoading && state.chats.isEmpty && !state.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredLocalChats = state.chats.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    final peerName = _getPeerName(c).toLowerCase();
                    final preview = c.lastMessage?.text?.toLowerCase() ?? '';
                    return peerName.contains(q) || preview.contains(q);
                  }).toList();

                  if (_searchQuery.isNotEmpty) {
                    return ListView(
                      padding: EdgeInsets.all(AppDimens.lg.r),
                      children: [
                        if (filteredLocalChats.isNotEmpty) ...[
                          _buildSectionHeader('Xabarlar'),
                          AppDimens.sm.height,
                          ...filteredLocalChats.map((chat) => Padding(
                                padding: EdgeInsets.only(bottom: AppDimens.md.h),
                                child: _ChatItem(chat: chat),
                              )),
                          AppDimens.lg.height,
                        ],
                        _buildSectionHeader('Global qidiruv'),
                        AppDimens.sm.height,
                        if (state.isSearching)
                          const Center(child: CircularProgressIndicator())
                        else if (state.searchResults.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Text(
                                context.l10n.resultNotFound,
                                style: AppStyles.bodySmall.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          )
                        else
                          ...state.searchResults.map((market) => Padding(
                                padding: EdgeInsets.only(bottom: AppDimens.md.h),
                                child: _SearchResultItem(market: market),
                              )),
                      ],
                    );
                  }

                  if (state.chats.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.noChats,
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<PrivateChatListBloc>().add(PrivateChatListLoad());
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppDimens.lg.r),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.chats.length,
                        separatorBuilder: (_, __) => AppDimens.md.height,
                        itemBuilder: (context, index) {
                          return _ChatItem(chat: state.chats[index]);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _getPeerName(PrivateChatModel chat) {
    final market = chat.market;
    if (market is Map) return market['name'] as String? ?? 'Market';
    return 'Chat';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppStyles.bodySmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final MarketModel market;

  const _SearchResultItem({required this.market});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<PrivateChatListBloc>().add(
              PrivateChatListOpenChat(
                receiverId: market.id,
                receiverRole: market.role,
                receiverName: market.name,
              ),
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
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              alignment: Alignment.center,
              child: Text(
                market.name.isNotEmpty ? market.name[0].toUpperCase() : '?',
                style: AppStyles.h4Bold
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
            AppDimens.md.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@${market.username}',
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final PrivateChatModel chat;

  const _ChatItem({required this.chat});

  String get _peerName {
    if (chat.market is Map) return chat.market['name'] as String? ?? 'Market';
    if (chat.client is Map) return chat.client['fullName'] as String? ?? 'Xaridor';
    return 'Chat';
  }

  @override
  Widget build(BuildContext context) {
    final lastMsg = chat.lastMessage;
    final timeStr = lastMsg != null
        ? DateFormat('HH:mm').format(lastMsg.createdAt.toLocal())
        : '';

    final peerId = (chat.market is Map ? chat.market['id'] : null) ?? 
                   (chat.client is Map ? chat.client['id'] : null) ?? '';
    final peerRole = chat.market is Map ? 'market' : 'client';

    return InkWell(
      onTap: () {
        context.read<PrivateChatListBloc>().add(PrivateChatListMarkRead(chat.id));
        context.push(
          Routes.getPrivateChat(chat.id),
          extra: {
            'name': _peerName,
            'receiverId': peerId,
            'receiverRole': peerRole,
          },
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
