import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../chat/data/models/message_model.dart';
import '../../../chat/data/services/audio_player_service.dart';
import '../../../chat/data/services/audio_recorder_service.dart';
import '../../../chat/presentation/managers/comment_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../chat/presentation/widgets/message_context_menu.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class ProductCommentChatPage extends StatefulWidget {
  /// Product name — shown in appbar
  final String productName;

  /// commentId from product entity
  final String commentId;

  const ProductCommentChatPage({
    super.key,
    required this.productName,
    required this.commentId,
  });

  @override
  State<ProductCommentChatPage> createState() => _ProductCommentChatPageState();
}

class _ProductCommentChatPageState extends State<ProductCommentChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _replyToId;
  String? _replyText;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentJoin(widget.commentId));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<CommentBloc>().add(CommentLoadMore(widget.commentId));
    }
  }

  @override
  void dispose() {
    context.read<CommentBloc>().add(CommentLeave(widget.commentId));
    _controller.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendText() {
    final commentId = context.read<CommentBloc>().state.chatId;
    if (commentId == null) return;

    final text = _controller.text.trim();
    final state = context.read<CommentBloc>().state;

    if (text.isEmpty && state.editingMessage == null) return;

    if (state.editingMessage != null) {
      context.read<CommentBloc>().add(CommentEditMessage(
            commentId: commentId,
            messageId: state.editingMessage!.id,
            text: text,
          ));
    } else {
      context.read<CommentBloc>().add(CommentSendMessage(
            commentId: commentId,
            text: text,
          ));
    }

    _controller.clear();
    _scrollToBottom();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<CommentBloc>().add(CommentSendImage(
            commentId: widget.commentId,
            filePath: image.path,
          ));
    }
  }

  void _handleMenuAction(BuildContext context, MessageAction action, MessageModel message) {
    final bloc = context.read<CommentBloc>();
    final commentId = bloc.state.chatId;
    if (commentId == null) return;

    switch (action) {
      case MessageAction.reply:
        bloc.add(CommentReplyToMessage(message));
        break;
      case MessageAction.copy:
        Clipboard.setData(ClipboardData(text: message.text ?? ''));
        break;
      case MessageAction.edit:
        if (message.type == 'text') {
          bloc.add(CommentStartEditing(message));
        }
        break;
      case MessageAction.delete:
        bloc.add(CommentDeleteMessage(commentId: commentId, messageId: message.id));
        break;
      default:
        break;
    }
  }

  void _startRecording() async {
    final recorder = context.read<AudioRecorderService>();
    final started = await recorder.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordingDuration += const Duration(seconds: 1));
      });
    }
  }

  void _stopRecording() async {
    _recordingTimer?.cancel();
    final result =
        await context.read<AudioRecorderService>().stopRecording();
    setState(() => _isRecording = false);
    if (result.path != null && mounted) {
      context.read<CommentBloc>().add(CommentSendAudio(
            commentId: widget.commentId,
            filePath: result.path!,
          ));
    }
  }

  void _scrollToBottom() {
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

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocListener<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
            );
          }
          if (state.editingMessage != null &&
              _controller.text != state.editingMessage!.text) {
            _controller.text = state.editingMessage!.text ?? '';
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CommonAppBar(
            title: widget.productName,
            leading: const AppBackButton(),
          ),
          body: BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: state.isLoading && state.messages.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : state.messages.isEmpty
                            ? Center(
                                child: Text(
                                  'Hali izohlar yo\'q.\nBirinchi bo\'lib yozing!',
                                  textAlign: TextAlign.center,
                                  style: AppStyles.bodySmall.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                padding: EdgeInsets.fromLTRB(
                                    AppDimens.md.w, AppDimens.sm.h,
                                    AppDimens.md.w, AppDimens.sm.h),
                                itemCount: state.messages.length +
                                    (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (ctx, index) {
                                  if (index == state.messages.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  final msg = state.messages[index];
                                  final isMine =
                                      msg.senderId == state.currentUserId ||
                                          msg.senderId == 'me';
                                  return _MessageBubble(
                                    message: msg,
                                    isMine: isMine,
                                    onAction: (action) => _handleMenuAction(context, action, msg),
                                  );
                                },
                              ),
                  ),

                  // Typing indicator
                  if (state.typingUserIds.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Yozmoqda...',
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),

                  _buildInputBar(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, CommentState state) {
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
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.editingMessage != null || state.replyingToMessage != null)
            _buildActionStatus(context, state),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach image
              IconButton(
                onPressed: _pickImage,
                icon: Icon(Icons.add_circle_outline_rounded,
                    color: theme.primaryColor, size: 26.r),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              // Input or recording
              Expanded(
                child: _isRecording
                    ? Container(
                        height: 40.h,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          children: [
                            const _RecordingDot(),
                            SizedBox(width: 8.w),
                            Text(
                              '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: AppStyles.bodySmall.copyWith(
                                  color: Colors.red, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      )
                    : TextField(
                        controller: _controller,
                        maxLines: 4,
                        minLines: 1,
                        style: AppStyles.bodySmall.copyWith(fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Izoh yozing...',
                          hintStyle: AppStyles.bodySmall.copyWith(
                              color: Colors.grey, fontSize: 13.sp),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                                color: theme.dividerColor
                                    .withValues(alpha: 0.2)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                        ),
                        onChanged: (text) {
                          setState(() {});
                          if (text.isNotEmpty) {
                            context
                                .read<CommentBloc>()
                                .add(CommentTyping(widget.commentId));
                          } else {
                            context
                                .read<CommentBloc>()
                                .add(CommentStopTyping(widget.commentId));
                          }
                        },
                      ),
              ),
              SizedBox(width: 8.w),
              // Send / mic button
              GestureDetector(
                onLongPress:
                    _controller.text.trim().isEmpty && state.editingMessage == null ? _startRecording : null,
                onLongPressUp:
                    _controller.text.trim().isEmpty && state.editingMessage == null ? _stopRecording : null,
                onTap: () {
                  if (_controller.text.trim().isNotEmpty) {
                    _sendText();
                  } else if (_isRecording) {
                    _stopRecording();
                  }
                },
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller.text.trim().isNotEmpty || state.editingMessage != null
                        ? Icons.send_rounded
                        : (_isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded),
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionStatus(BuildContext context, CommentState state) {
    final theme = Theme.of(context);
    final isEditing = state.editingMessage != null;
    final msg = isEditing ? state.editingMessage : state.replyingToMessage;

    return Container(
      padding: EdgeInsets.fromLTRB(40.w, 4.h, 8.w, 4.h),
      margin: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_rounded : Icons.reply_rounded,
            size: 16.r,
            color: theme.primaryColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Tahrirlash' : (msg?.senderName ?? 'Izoh'),
                  style: AppStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  msg?.text ?? '[Media]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.bodySmall.copyWith(
                    color: Colors.grey,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<CommentBloc>().add(const CommentCancelAction());
              if (isEditing) _controller.clear();
            },
            icon: Icon(Icons.close_rounded, size: 18.r, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Message Bubble
// ══════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final Function(MessageAction)? onAction;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());

    return GestureDetector(
      onTap: () => _showMessageDialog(context, message, isMine),
      onLongPress: onAction != null
          ? () => onAction!(MessageAction.reply)
          : null,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 6.h,
            left: isMine ? 60.w : 0,
            right: isMine ? 0 : 60.w,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name (for others)
              if (!isMine)
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
                  child: Text(
                    message.senderName,
                    style: AppStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isMine ? theme.primaryColor : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                    bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isMine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.type == 'text' && message.text != null)
                      Text(
                        message.text!,
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 13.sp,
                          color: isMine
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          height: 1.4,
                        ),
                      )
                    else if (message.type == 'image' &&
                        message.mediaPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _buildImage(),
                      )
                    else if (message.type == 'audio' &&
                        message.mediaPath != null)
                      _AudioBubble(
                        url: message.localPath ?? message.mediaPath!,
                        isMine: isMine,
                      )
                    else
                      Text('[Media]',
                          style: AppStyles.bodySmall.copyWith(
                              color: isMine ? Colors.white : null)),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 9.sp,
                            color: isMine ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        if (isMine) ...[
                          SizedBox(width: 4.w),
                          _StatusIcon(message: message),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context, MessageModel message, bool isMine) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim, __) => _buildMenu(ctx, anim, offset, size, screenSize, message, isMine),
    );
  }

  Widget _buildMenu(BuildContext context, Animation<double> anim, Offset offset, Size size, Size screenSize, MessageModel message, bool isMine) {
    final double menuHeightEst = 250.h;
    final bool showBelow = (offset.dy + size.height + menuHeightEst) < screenSize.height;
    final double? top = showBelow ? offset.dy + size.height + 8.h : null;
    final double? bottom = showBelow ? null : (screenSize.height - offset.dy + 8.h);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Original message clone
        Positioned(
          top: offset.dy,
          left: offset.dx,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: _MessageBubble(message: message, isMine: isMine),
          ),
        ),
        // Menu
        AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            return Positioned(
              top: top,
              bottom: bottom,
              left: isMine ? null : offset.dx,
              right: isMine ? (screenSize.width - (offset.dx + size.width)) : null,
              child: Transform.scale(
                scale: anim.value,
                alignment: showBelow 
                    ? (isMine ? Alignment.topRight : Alignment.topLeft)
                    : (isMine ? Alignment.bottomRight : Alignment.bottomLeft),
                child: Material(
                  color: Colors.transparent,
                  child: MessageContextMenu(
                    message: message.toEntity(''),
                    isMine: isMine,
                    onAction: (action) {
                      Navigator.pop(context);
                      if (onAction != null) onAction!(action);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildImage() {
    if (message.localPath != null && message.localPath!.isNotEmpty) {
      final file = File(message.localPath!);
      if (file.existsSync()) {
        return Image.file(file, width: 220.w, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _networkImage());
      }
    }
    if (message.isSending && message.mediaPath != null) {
      final file = File(message.mediaPath!);
      if (file.existsSync()) {
        return Image.file(file, width: 220.w, fit: BoxFit.cover);
      }
    }
    return _networkImage();
  }

  Widget _networkImage() {
    final url = message.mediaPath!;
    final fullUrl =
        url.startsWith('http') ? url : 'http://89.223.126.116:3003/$url';
    return Image.network(
      fullUrl,
      width: 220.w,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : SizedBox(
              width: 220.w,
              height: 160.h,
              child: const Center(child: CircularProgressIndicator()),
            ),
      errorBuilder: (_, __, ___) => SizedBox(
        width: 220.w,
        height: 100.h,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageModel message;
  const _StatusIcon({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSending) {
      return Icon(Icons.access_time_rounded, size: 10.r, color: Colors.white70);
    }
    if (message.status == 'SEEN') {
      return Icon(Icons.done_all_rounded, size: 14.r, color: Colors.white);
    }
    return Icon(Icons.done_rounded, size: 14.r, color: Colors.white70);
  }
}

// ══════════════════════════════════════════════════════════════
// Audio Bubble
// ══════════════════════════════════════════════════════════════

class _AudioBubble extends StatefulWidget {
  final String url;
  final bool isMine;
  const _AudioBubble({required this.url, required this.isMine});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  @override
  void initState() {
    super.initState();
    final player = context.read<AudioPlayerService>();
    _stateSub = player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _posSub = player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = widget.isMine ? Colors.white : Theme.of(context).primaryColor;
    return SizedBox(
      width: 190.w,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final p = context.read<AudioPlayerService>();
              _isPlaying ? p.pause() : p.play(widget.url);
            },
            icon: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: color,
              size: 28.r,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.r),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.3),
                thumbColor: color,
              ),
              child: Slider(
                value: _position.inMilliseconds
                    .toDouble()
                    .clamp(0, _duration.inMilliseconds.toDouble()),
                max: _duration.inMilliseconds > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (v) {
                  context
                      .read<AudioPlayerService>()
                      .seek(Duration(milliseconds: v.toInt()));
                },
              ),
            ),
          ),
          Text(
            _fmt(_duration > Duration.zero ? _duration - _position : Duration.zero),
            style: TextStyle(color: color, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Recording Dot
// ══════════════════════════════════════════════════════════════

class _RecordingDot extends StatefulWidget {
  const _RecordingDot();
  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: Container(
          width: 8.r,
          height: 8.r,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      );
}
