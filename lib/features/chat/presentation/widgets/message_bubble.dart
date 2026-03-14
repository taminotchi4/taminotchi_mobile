import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../managers/chat_bloc.dart';
import '../managers/chat_event.dart';
import '../managers/chat_state.dart';
import 'chat_image_viewer.dart';
import 'message_context_menu.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class MessageBubble extends StatefulWidget {
  final ChatMessageEntity message;
  final bool isMine;
  final bool isSelected;
  final Function(String messageId, int imageIndex, String path)? onImageTap;
  final Function(String messageId)? onReplyTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.isSelected = false,
    this.onImageTap,
    this.onReplyTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;
  bool _shouldReply = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _dragOffset = _dragOffset * (1 - _controller.value);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Only allow swiping from right to left (negative delta)
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset > 0) _dragOffset = 0;
      if (_dragOffset < -80.w) _dragOffset = -80.w; // Limit max drag

      _shouldReply = _dragOffset < -60.w;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_shouldReply) {
      context.read<ChatBloc>().add(ChatReplyToMessage(widget.message));
      HapticFeedback.lightImpact();
    }
    _controller.forward(from: 0);
    _shouldReply = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageDialog(context),
      onTap: () {
        if (widget.isSelected || context.read<ChatBloc>().state.selectedMessageIds.isNotEmpty) {
           context.read<ChatBloc>().add(ChatToggleMessageSelection(widget.message.id));
        }
      },
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Reply Icon reveal
          if (_dragOffset < 0)
            Positioned(
              right: 15.w,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_dragOffset.abs() / 80.w).clamp(0, 1),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: _shouldReply ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.reply,
                    size: 20.sp,
                    color: _shouldReply ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          // Content
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Align(
              alignment: widget.isMine ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4.h),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: widget.isSelected 
                      ? AppColors.mainBlue.withOpacity(0.3) 
                      : (widget.isMine ? const Color(0xFFDCF8C6) : Theme.of(context).cardColor),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: widget.isMine ? Radius.circular(12.r) : Radius.zero,
                    bottomRight: widget.isMine ? Radius.zero : Radius.circular(12.r),
                  ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.replyToMessage != null) _buildReplyPreviewInBubble(context, widget.message.replyToMessage!),
                  _buildContent(context),
                  if (widget.message.caption != null && widget.message.caption!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      widget.message.caption!,
                      style: AppStyles.bodyRegular.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.message.type != ChatMessageType.text && widget.message.type != ChatMessageType.image)
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            FileUtils.getFileSize(widget.message.content),
                            style: AppStyles.bodySmall.copyWith(fontSize: 10.sp, color: Colors.grey),
                          ),
                        ),
                      if (widget.isMine) ...[
                        _StatusIcon(status: widget.message.status),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        DateFormat('HH:mm').format(widget.message.createdAt),
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.message.type) {
      case ChatMessageType.text:
        return Text(
          widget.message.content,
          style: AppStyles.bodyRegular.copyWith(
            color: AppColors.black,
          ),
        );
      case ChatMessageType.image:
        return Stack(
          children: [
            _buildImage(context, widget.message.content, 0, [widget.message.content], width: 200.w, height: 200.w),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  FileUtils.getFileSize(widget.message.content),
                  style: AppStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        );
      case ChatMessageType.album:
        final images = widget.message.images;
        final count = images.length;

        if (count == 1) {
          return _buildImage(context, images.first, 0, images, height: 200.h, width: 200.w);
        } else if (count == 2) {
          return Row(
            children: [
              Expanded(child: _buildImage(context, images[0], 0, images, height: 150.h)),
              SizedBox(width: 2.w),
              Expanded(child: _buildImage(context, images[1], 1, images, height: 150.h)),
            ],
          );
        } else if (count == 3) {
          return Column(
            children: [
              _buildImage(context, images[0], 0, images, height: 150.h, width: double.infinity),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(child: _buildImage(context, images[1], 1, images, height: 150.h)),
                  SizedBox(width: 2.w),
                  Expanded(child: _buildImage(context, images[2], 2, images, height: 150.h)),
                ],
              ),
            ],
          );
        } else if (count == 4) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildImage(context, images[0], 0, images, height: 100.h)),
                  SizedBox(width: 2.w),
                  Expanded(child: _buildImage(context, images[1], 1, images, height: 100.h)),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(child: _buildImage(context, images[2], 2, images, height: 100.h)),
                  SizedBox(width: 2.w),
                  Expanded(child: _buildImage(context, images[3], 3, images, height: 100.h)),
                ],
              ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            return _buildImage(context, images[index], index, images, fit: BoxFit.cover);
          },
        );
      case ChatMessageType.audio:
        return _AudioMessage(message: widget.message);
    }
  }
  Widget _buildImage(BuildContext context, String path, int index, List<String> allImages, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    final tag = '${widget.message.id}_$index';
    return GestureDetector(
      onTap: () {
        if (widget.onImageTap != null) {
          widget.onImageTap!(widget.message.id, index, path);
          return;
        }

        final items = allImages.asMap().entries.map((entry) {
          return GalleryImageItem(
            path: entry.value,
            tag: '${widget.message.id}_${entry.key}',
          );
        }).toList();

        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => ChatImageViewer(
              items: items,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.file(
            File(path),
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreviewInBubble(BuildContext context, ChatMessageEntity replyTo) {
    String content = replyTo.content;
    if (replyTo.type == ChatMessageType.image) content = "Rasm";
    else if (replyTo.type == ChatMessageType.album) content = "Albom";
    else if (replyTo.type == ChatMessageType.audio) content = "Audio xabar";

    return GestureDetector(
      onTap: () {
        if (widget.onReplyTap != null) widget.onReplyTap!(replyTo.id);
      },
      child: Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 2.w)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            replyTo.senderName,
            style: AppStyles.bodySmall.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
          Text(
            content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodySmall.copyWith(
              color: Colors.black54,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    ));
  }

  void _showMessageDialog(BuildContext context) {
    if (!context.mounted) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final chatBloc = context.read<ChatBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black26, // Lighter barrier color since we have blur
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BlocProvider.value(
          value: chatBloc,
          child: Stack(
            children: [
              // Blur Background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Message Clone
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Positioned(
                    top: offset.dy,
                    left: offset.dx,
                    width: size.width,
                    height: size.height,
                    child: Transform.scale(
                      scale: 1.0 + (0.02 * animation.value), // Subtle pop effect
                      child: Material(
                        color: Colors.transparent,
                        child: AbsorbPointer(
                          child: MessageBubble(
                            message: widget.message,
                            isMine: widget.isMine,
                            isSelected: widget.isSelected,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Menu
              _buildMenuPositioned(context, offset, size, screenSize, animation),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Widget _buildMenuPositioned(BuildContext context, Offset offset, Size size, Size screenSize, Animation<double> animation) {
    // Logic for positioning
    // Estimate menu height ~ 350
    final double menuHeightEst = 350.h;
    final bool showBelow = (offset.dy + size.height + menuHeightEst) < screenSize.height;

    final double? top = showBelow ? offset.dy + size.height + 8.h : null;
    final double? bottom = showBelow ? null : (screenSize.height - offset.dy + 8.h);

    final bool alignRight = widget.isMine;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          top: top,
          bottom: bottom,
          left: alignRight ? null : offset.dx,
          right: alignRight ? (screenSize.width - (offset.dx + size.width)) : null,
          child: Transform.scale(
            scale: animation.value,
            alignment: showBelow 
                ? (alignRight ? Alignment.topRight : Alignment.topLeft)
                : (alignRight ? Alignment.bottomRight : Alignment.bottomLeft),
            child: Material(
              color: Colors.transparent,
              child: MessageContextMenu(
                message: widget.message,
                isMine: widget.isMine,
                borderRadius: BorderRadius.circular(16.r),
                onAction: (action) {
                  Navigator.pop(context);
                  _handleAction(context, action);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAction(BuildContext context, MessageAction action) {
    final bloc = context.read<ChatBloc>();
    switch (action) {
      case MessageAction.reply:
        bloc.add(ChatReplyToMessage(widget.message));
        break;
      case MessageAction.edit:
        bloc.add(ChatStartEditing(widget.message));
        break;
      case MessageAction.copy:
        Clipboard.setData(ClipboardData(text: widget.message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nusxalandi'), duration: Duration(seconds: 1)),
        );
        break;
      case MessageAction.forward:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uzatish funksiyasi tez orada...'), duration: Duration(seconds: 1)),
        );
        break;
      case MessageAction.delete:
        bloc.add(ChatDeleteMessage(widget.message.id));
        break;
      case MessageAction.select:
        bloc.add(ChatToggleMessageSelection(widget.message.id));
        break;
    }
  }
}

class _AudioMessage extends StatelessWidget {
  final ChatMessageEntity message;

  const _AudioMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isPlaying = state.playingMessageId == message.id;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                context.read<ChatBloc>().add(
                      ChatToggleMessageAudioPlayback(
                        messageId: message.id,
                        audioPath: message.content,
                      ),
                    );
              },
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
            AppDimens.sm.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(20, (index) {
                    final height = Random().nextInt(20) + 5.0;
                    return Container(
                      margin: EdgeInsets.only(right: 2.w),
                      width: 2.w,
                      height: height.h,
                      color: isPlaying ? Theme.of(context).primaryColor : Colors.grey[400],
                    );
                  }),
                ),
                AppDimens.xs.height,
                Text(
                  FileUtils.getAudioDuration(message.content),
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 14.r, color: color);
  }
}
