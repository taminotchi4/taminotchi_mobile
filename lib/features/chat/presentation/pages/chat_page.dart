import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../managers/chat_bloc.dart';
import '../managers/chat_event.dart';
import '../managers/chat_state.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_image_viewer.dart';
import '../widgets/chat_input_section.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String sellerId;
  final String userId;
  final String? sellerName;
  final String? sellerRole;

  const ChatPage({
    super.key,
    required this.sellerId,
    required this.userId,
    this.sellerName,
    this.sellerRole,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
          ChatStarted(sellerId: widget.sellerId, userId: widget.userId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _performInitialScroll(List<ChatMessageEntity> messages) {
    if (_initialScrollDone) return;

    String? targetId;
    int firstUnreadIndex = -1;

    // Find first unread incoming message
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      // Assuming isSeller means incoming. And non-read status means unread.
      if (msg.isSeller && msg.status != MessageStatus.read) {
        firstUnreadIndex = i;
        break;
      }
    }

    if (firstUnreadIndex != -1) {
      if (firstUnreadIndex > 0) {
        // Target is the message BEFORE the first unread (Last Read Message)
        targetId = messages[firstUnreadIndex - 1].id;
      } else {
        // First message is unread, target it directly (align to top)
        targetId = messages[0].id;
      }
    } else if (messages.isNotEmpty) {
      // All read, scroll to bottom (last message)
      targetId = messages.last.id;
    }

    if (targetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Double check context and key existence
        if (_messageKeys.containsKey(targetId)) {
           final key = _messageKeys[targetId];
           if (key?.currentContext != null) {
              Scrollable.ensureVisible(
                key!.currentContext!,
                alignment: firstUnreadIndex == 0 ? 1.0 : 0.0, // Top if 1st is unread, Bottom otherwise
                duration: const Duration(milliseconds: 100), // Instant/Fast jump
              );
           }
        } else if (firstUnreadIndex == -1 && _scrollController.hasClients) {
           // Fallback for bottom scroll
           _scrollController.jumpTo(0);
        }
        _initialScrollDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        sellerName: widget.sellerName,
        sellerRole: widget.sellerRole,
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          // Handle initial scroll on first load
          if (!_initialScrollDone && !state.isLoading && state.messages.isNotEmpty) {
             _performInitialScroll(state.messages);
          }

          // Handle auto-scroll for NEW messages (only if initial scroll is done)
          if (_initialScrollDone && state.messages.isNotEmpty) {
            final lastMessage = state.messages.last;
            if (!lastMessage.isSeller) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0, 
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          }
        },
        child: Column(
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
                        'Xabarlar yo\'q',
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    );
                  }
                  
                  // Reset keys if messages change drastically? 
                  // Keys should be stable by ID.
                  
                  return ListView(
                    reverse: true,
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppDimens.lg.r),
                    children: state.messages.reversed.map((message) {
                      if (!_messageKeys.containsKey(message.id)) {
                        _messageKeys[message.id] = GlobalKey();
                      }
                      final isMine = !message.isSeller;
                      final isSelected = state.selectedMessageIds.contains(message.id);
                      return Container(
                         key: _messageKeys[message.id],
                         child: MessageBubble(
                           message: message,
                           isMine: isMine,
                           isSelected: isSelected,
                           onImageTap: (mId, mIndex, mPath) => _handleImageTap(state.messages, mId, mIndex),
                           onReplyTap: (replyId) => _jumpToMessage(replyId),
                         ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const ChatInputSection(),
          ],
        ),
      ),
    );
  }

  void _handleImageTap(List<ChatMessageEntity> messages, String targetMessageId, int targetImageIndex) {
    final allItems = <GalleryImageItem>[];
    int initialIndex = 0;

    for (var msg in messages) {
       if (msg.type == ChatMessageType.image) {
          if (msg.id == targetMessageId && targetImageIndex == 0) initialIndex = allItems.length;
          allItems.add(GalleryImageItem(path: msg.content, tag: '${msg.id}_0'));
       } else if (msg.type == ChatMessageType.album) {
          for (var i = 0; i < msg.images.length; i++) {
             if (msg.id == targetMessageId && targetImageIndex == i) initialIndex = allItems.length;
             allItems.add(GalleryImageItem(path: msg.images[i], tag: '${msg.id}_$i'));
          }
       }
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => ChatImageViewer(
          items: allItems,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _jumpToMessage(String messageId) {
    if (_messageKeys.containsKey(messageId)) {
      final context = _messageKeys[messageId]!.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    }
  }
}
