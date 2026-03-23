import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../data/models/message_model.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/audio_recorder_service.dart';
import '../managers/private_chat_bloc.dart';

class PrivateChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverRole;
  final String? receiverName;

  const PrivateChatPage({
    super.key,
    required this.receiverId,
    required this.receiverRole,
    this.receiverName,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    // The Bloc.create in the router already dispatched the appropriate event
    // (PrivateChatStartedWithId or PrivateChatStarted). No need to re-dispatch here.
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // In a reversed list, reaching maxScrollExtent = oldest messages (top)
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<PrivateChatBloc>().add(const PrivateChatLoadMore());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final chatId = context.read<PrivateChatBloc>().state.chatId;
    if (chatId == null) return;
    context.read<PrivateChatBloc>().add(PrivateChatSendMessage(
          chatId: chatId,
          text: text,
        ));
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // visually bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _pickImage() async {
    final chatId = context.read<PrivateChatBloc>().state.chatId;
    if (chatId == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      context.read<PrivateChatBloc>().add(PrivateChatSendMedia(
            chatId: chatId,
            filePath: image.path,
            type: 'image',
          ));
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
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration += const Duration(seconds: 1));
      });
    }
  }

  void _stopRecording() async {
    final chatId = context.read<PrivateChatBloc>().state.chatId;
    if (chatId == null) return;

    _recordingTimer?.cancel();
    final result = await context.read<AudioRecorderService>().stopRecording();
    setState(() => _isRecording = false);

    if (result.path != null) {
      if (!mounted) return;
      context.read<PrivateChatBloc>().add(PrivateChatSendMedia(
            chatId: chatId,
            filePath: result.path!,
            type: 'audio',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CommonAppBar(
          title: widget.receiverName ?? 'Chat',
          leading: const AppBackButton(),
        ),
        body: BlocBuilder<PrivateChatBloc, PrivateChatState>(
          builder: (context, state) {
            return Column(
              children: [
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
                              reverse: true,
                              padding: EdgeInsets.all(AppDimens.md.r),
                              // +1 for load-more indicator at top
                              itemCount: state.messages.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Load-more spinner at the visual top
                                if (index == state.messages.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                final msg = state.messages[index];
                                // Robust logic for private chat: if it's not from the peer, it's from me
                                final isMine = msg.senderId != widget.receiverId || 
                                             msg.senderId == 'me' ||
                                             (state.currentUserId != null && msg.senderId == state.currentUserId);
                                return _MessageBubble(
                                  message: msg,
                                  isMine: isMine,
                                );
                              },
                            ),
                ),
                
                if (state.isPeerTyping)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                         Text(
                          'Yozmoqda...',
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
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

  Widget _buildInputBar(BuildContext context, PrivateChatState state) {
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
          IconButton(
            onPressed: _pickImage,
            icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 26.r),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
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
                        'Yozilmoqda: ${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: AppStyles.bodySmall.copyWith(color: Colors.red, fontSize: 12.sp),
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
                    hintText: 'Xabar yozing...',
                    hintStyle: AppStyles.bodySmall.copyWith(
                      color: Colors.grey,
                      fontSize: 13.sp,
                    ),
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
                    setState(() {}); // Toggle mic/send
                    final chatId = state.chatId;
                    if (chatId != null && text.isNotEmpty && !_isTyping) {
                      _isTyping = true;
                      context.read<PrivateChatBloc>().add(PrivateChatTyping(chatId));
                    }
                  },
                ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onLongPress: _controller.text.trim().isEmpty ? _startRecording : null,
            onLongPressUp: _controller.text.trim().isEmpty ? _stopRecording : null,
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
                _controller.text.trim().isNotEmpty 
                  ? Icons.send_rounded 
                  : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                color: Colors.white, 
                size: 20.r
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());
    final effectivelyMine = isMine || message.senderId == 'me';

    return Align(
      alignment: effectivelyMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 4.h,
          left: effectivelyMine ? 60.w : 0,
          right: effectivelyMine ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: effectivelyMine ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(effectivelyMine ? 16.r : 4.r),
            bottomRight: Radius.circular(effectivelyMine ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: effectivelyMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == 'text' && message.text != null)
              Text(
                message.text!,
                style: AppStyles.bodySmall.copyWith(
                  color: effectivelyMine ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              )
            else if (message.type == 'image' && message.mediaPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildImage(context),
              )
            else if (message.type == 'audio' && message.mediaPath != null)
              _AudioPlayer(
                url: message.localPath ?? message.mediaPath!,
                isMine: effectivelyMine,
              )
            else
              const Text('[Media]'),
              
            SizedBox(height: 2.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: AppStyles.bodySmall.copyWith(
                    fontSize: 9.sp,
                    color: effectivelyMine ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (effectivelyMine) ...[
                  SizedBox(width: 4.w),
                  _buildStatusIcon(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // 1. Use locally cached file if available
    if (message.localPath != null && message.localPath!.isNotEmpty) {
      final file = File(message.localPath!);
      return Image.file(file, width: 220.w, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _networkImage());
    }
    // 2. While sending: original local pick path
    if (message.isSending && message.mediaPath != null) {
      final file = File(message.mediaPath!);
      if (file.existsSync()) {
        return Image.file(file, width: 220.w, fit: BoxFit.cover);
      }
    }
    // 3. Fallback to network URL
    return _networkImage();
  }

  Widget _networkImage() {
    return Image.network(
      message.mediaPath!,
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

  Widget _buildStatusIcon(BuildContext context) {
    if (message.isSending) {
      return Icon(Icons.access_time_rounded, size: 10.r, color: Colors.white70);
    }
    if (message.status == 'SEEN') {
      return Icon(Icons.done_all_rounded, size: 14.r, color: Colors.white);
    }
    return Icon(Icons.done_rounded, size: 14.r, color: Colors.white70);
  }
}

class _AudioPlayer extends StatefulWidget {
  final String url;
  final bool isMine;
  const _AudioPlayer({required this.url, required this.isMine});

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
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
      if (mounted) setState(() => _isPlaying = (s == PlayerState.playing));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isMine ? Colors.white : theme.primaryColor;
    
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final player = context.read<AudioPlayerService>();
              if (_isPlaying) player.pause(); else player.play(widget.url);
            },
            icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: color, size: 28.r),
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
                inactiveTrackColor: color.withOpacity(0.3),
                thumbColor: color,
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(
                value: _position.inMilliseconds.toDouble().clamp(0, (_duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 0)),
                max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0, 
                onChanged: (val) {
                   context.read<AudioPlayerService>().seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(color: color, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
  const _RecordingDot();
  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _anim, child: Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)));
}
