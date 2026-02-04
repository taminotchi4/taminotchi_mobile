import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../managers/chat_bloc.dart';
import '../managers/chat_event.dart';
import '../managers/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String sellerId;
  final String userId;

  const ChatPage({
    super.key,
    required this.sellerId,
    required this.userId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
          ChatStarted(sellerId: widget.sellerId, userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Chat',
        leading: AppBackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Xabarlar yoq',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodySmall.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(AppDimens.lg.r),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMine = !message.isSeller;
                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: AppDimens.sm.h),
                        padding: EdgeInsets.all(AppDimens.md.r),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(AppDimens.imageRadius.r),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        child: _messageContent(context, message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _inputBar(context),
        ],
      ),
    );
  }

  Widget _messageContent(BuildContext context, ChatMessageEntity message) {
    if (message.type == ChatMessageType.text) {
      return Text(
        message.content,
        style: AppStyles.bodyRegular.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      );
    }
    final label = message.type == ChatMessageType.image ? 'Image' : 'Audio';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgIcon(
          assetPath:
              message.type == ChatMessageType.image ? AppIcons.gallery : AppIcons.audio,
          size: AppDimens.iconMd,
          color: Theme.of(context).iconTheme.color,
        ),
        AppDimens.sm.width,
        Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _inputBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppDimens.lg.w,
          AppDimens.sm.h,
          AppDimens.lg.w,
          AppDimens.sm.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: AppDimens.borderWidth.w,
            ),
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => context.read<ChatBloc>().add(
                    const ChatSendMessage(
                      type: ChatMessageType.image,
                      content: 'image',
                    ),
                  ),
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              child: Padding(
                padding: EdgeInsets.all(AppDimens.sm.r),
                child: AppSvgIcon(
                  assetPath: AppIcons.gallery,
                  size: AppDimens.iconMd,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            InkWell(
              onTap: () => context.read<ChatBloc>().add(
                    const ChatSendMessage(
                      type: ChatMessageType.audio,
                      content: 'audio',
                    ),
                  ),
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              child: Padding(
                padding: EdgeInsets.all(AppDimens.sm.r),
                child: AppSvgIcon(
                  assetPath: AppIcons.audio,
                  size: AppDimens.iconMd,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            AppDimens.sm.width,
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Xabar yozing...',
                  hintStyle: AppStyles.bodyRegular.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: AppDimens.borderWidth.w,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: AppDimens.borderWidth.w,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: AppDimens.borderWidth.w,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: AppDimens.sm.h,
                    horizontal: AppDimens.md.w,
                  ),
                ),
              ),
            ),
            AppDimens.sm.width,
            InkWell(
              onTap: () {
                final text = _controller.text;
                _controller.clear();
                context.read<ChatBloc>().add(
                      ChatSendMessage(
                        type: ChatMessageType.text,
                        content: text,
                      ),
                    );
              },
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              child: Container(
                padding: EdgeInsets.all(AppDimens.sm.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.circular(AppDimens.imageRadius.r),
                ),
                child: const AppSvgIcon(
                  assetPath: AppIcons.send,
                  size: AppDimens.iconMd,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
