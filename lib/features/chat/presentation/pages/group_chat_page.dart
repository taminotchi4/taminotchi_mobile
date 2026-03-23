import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../data/models/message_model.dart';
import '../managers/group_chat_bloc.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;

  const GroupChatPage({super.key, required this.groupId});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<GroupChatBloc>().add(GroupChatStarted(widget.groupId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<GroupChatBloc>().add(GroupChatSendMessage(
          groupId: widget.groupId,
          text: text,
        ));
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: '',
          leading: const AppBackButton(),
        ),
        body: BlocBuilder<GroupChatBloc, GroupChatState>(
          builder: (context, state) {
            final groupName = state.group?.name ?? 'Guruh';
            return Column(
              children: [
                // Group name bar
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: AppStyles.h4Bold.copyWith(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      if (state.group?.membersCount != null)
                        Text(
                          '${state.group!.membersCount} a\'zo',
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),

                // Typing indicator
                if (state.typingUsers.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${state.typingUsers.join(", ")} yozmoqda...',
                          style: AppStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.messages.isEmpty
                          ? Center(
                              child: Text(
                                'Xabarlar yo\'q',
                                style: AppStyles.bodySmall.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(AppDimens.md.r),
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                return _GroupMessageBubble(message: state.messages[index]);
                              },
                            ),
                ),

                _buildInputBar(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, GroupChatState state) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.md.w,
        AppDimens.sm.h,
        AppDimens.md.w,
        MediaQuery.of(context).padding.bottom + AppDimens.sm.h,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              style: AppStyles.bodySmall.copyWith(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Xabar yozing...',
                hintStyle: AppStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 13.sp),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  context.read<GroupChatBloc>().add(GroupChatTyping(widget.groupId));
                }
              },
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _sendText,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 18.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupMessageBubble extends StatelessWidget {
  final MessageModel message;

  const _GroupMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                child: Text(
                  message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                  style: AppStyles.bodySmall.copyWith(
                    color: theme.primaryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                message.senderName,
                style: AppStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: AppStyles.bodySmall.copyWith(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 34.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: message.type == 'text' && message.text != null
                  ? Text(
                      message.text!,
                      style: AppStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    )
                  : Text('[Media]', style: AppStyles.bodySmall.copyWith(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
