import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../managers/chat_bloc.dart';
import '../managers/chat_event.dart';
import '../managers/chat_state.dart';
import 'chat_waveforms.dart';
import 'image_picker_sheet.dart';

class ChatInputSection extends StatefulWidget {
  const ChatInputSection({super.key});

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (_hasText != hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showImagePicker(BuildContext context) {
    final galleryService = context.read<ChatBloc>().galleryService;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatImagePickerSheet(galleryService: galleryService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) => previous.editingMessage != current.editingMessage,
      listener: (context, state) {
        if (state.editingMessage != null) {
          _controller.text = state.editingMessage!.content;
           setState(() { _hasText = true; });
        } else {
          _controller.clear();
          setState(() { _hasText = false; });
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.recordedAudioPath != null) {
            return _ChatAudioPreview(state: state);
          }

          if (state.selectedImages.isNotEmpty) {
            return _ChatImageSelectionPreview(state: state);
          }

          return _UnifiedChatInputBar(
            controller: _controller,
            hasText: _hasText,
            isRecording: state.isRecordingAudio,
            recordingWaveformData: state.recordingWaveformData,
            editingMessage: state.editingMessage,
            replyingMessage: state.replyingMessage,
            onCancelAction: () {
              if (state.editingMessage != null) {
                context.read<ChatBloc>().add(const ChatCancelEditing());
              }
              if (state.replyingMessage != null) {
                context.read<ChatBloc>().add(const ChatCancelReply());
              }
            },
            onSend: (text) {
              if (state.editingMessage != null) {
                context.read<ChatBloc>().add(ChatSubmitEdit(text));
              } else {
                context.read<ChatBloc>().add(
                  ChatSendMessage(type: ChatMessageType.text, content: text),
                );
              }
              _controller.clear();
            },
            onImagePicker: () => _showImagePicker(context),
            onRecordStart: () => context.read<ChatBloc>().add(const ChatStartRecordingAudio()),
            onRecordStop: () => context.read<ChatBloc>().add(const ChatStopRecordingAudio()),
          );
        },
      ),
    );
  }
}

class _UnifiedChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final bool isRecording;
  final List<double>? recordingWaveformData;
  final Function(String) onSend;
  final VoidCallback onImagePicker;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;

  final ChatMessageEntity? editingMessage;
  final ChatMessageEntity? replyingMessage;
  final VoidCallback onCancelAction;

  const _UnifiedChatInputBar({
    required this.controller,
    required this.hasText,
    required this.isRecording,
    required this.recordingWaveformData,
    required this.onSend,
    required this.onImagePicker,
    required this.onRecordStart,
    required this.onRecordStop,
    this.editingMessage,
    this.replyingMessage,
    required this.onCancelAction,
  });

  @override
  Widget build(BuildContext context) {
    final showPreview = editingMessage != null || replyingMessage != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w, vertical: AppDimens.sm.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1.w,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChatActionPreview(
              editingMessage: editingMessage,
              replyingMessage: replyingMessage,
              onCancelAction: onCancelAction,
            ),
            Row(
              children: [
                if (isRecording) ...[
                  // Recording UI (Left side)
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 24.r,
                      color: AppColors.red,
                    ),
                  ),
                  AppDimens.sm.width,
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Audio yozilmoqda...",
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppDimens.sm.width,
                        Expanded(
                          child: SizedBox(
                            height: 30.h,
                            child: recordingWaveformData != null
                                ? RealTimeWaveform(data: recordingWaveformData!)
                                : const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Normal UI (Left side)
                  // Disable attachment if editing/replying? No, reply allows attachment. Edit usually doesn't change type.
                  if (editingMessage == null)
                    InkWell(
                      onTap: onImagePicker,
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
                  if (editingMessage == null) AppDimens.sm.width,
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: AppStyles.bodyRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Xabar yozing...',
                        hintStyle: AppStyles.bodyRegular.copyWith(color: Theme.of(context).hintColor),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: AppDimens.sm.h,
                          horizontal: AppDimens.md.w,
                        ),
                      ),
                    ),
                  ),
                ],
                
                AppDimens.sm.width,
                
                // Send / Mic Button / Check Button
                if (hasText || editingMessage != null)
                  InkWell(
                    onTap: () => onSend(controller.text.trim()),
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        editingMessage != null ? Icons.check : Icons.send, 
                        size: 20.r, 
                        color: Colors.white
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onLongPressStart: (_) => onRecordStart(),
                    onLongPressEnd: (_) => onRecordStop(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isRecording 
                            ? AppColors.red.withOpacity(0.1) 
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 20.r,
                        color: isRecording 
                            ? AppColors.red 
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildPreview helper as it's replaced by _ChatActionPreview widget
}

class _ChatActionPreview extends StatelessWidget {
  final ChatMessageEntity? editingMessage;
  final ChatMessageEntity? replyingMessage;
  final VoidCallback onCancelAction;

  const _ChatActionPreview({
    this.editingMessage,
    this.replyingMessage,
    required this.onCancelAction,
  });

  @override
  Widget build(BuildContext context) {
    if (editingMessage == null && replyingMessage == null) return const SizedBox();
    
    final isEdit = editingMessage != null;
    final message = isEdit ? editingMessage! : replyingMessage!;

    String content = message.content;
    if (message.type == ChatMessageType.image) content = "Rasm";
    else if (message.type == ChatMessageType.album) content = "Albom";
    else if (message.type == ChatMessageType.audio) content = "Audio xabar";

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.only(left: 10.w, right: 0.w, top: 4.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 3.w)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.reply, color: Theme.of(context).primaryColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? "Xabarni tahrirlash" : "Javob yozish: ${message.senderName}",
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20.r, color: Colors.grey),
            onPressed: onCancelAction,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

class _ChatAudioPreview extends StatelessWidget {
  final ChatState state;

  const _ChatAudioPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChatActionPreview(
              replyingMessage: state.replyingMessage,
              editingMessage: state.editingMessage,
              onCancelAction: () {
                if (state.editingMessage != null) {
                  context.read<ChatBloc>().add(const ChatCancelEditing());
                }
                if (state.replyingMessage != null) {
                  context.read<ChatBloc>().add(const ChatCancelReply());
                }
              },
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => context.read<ChatBloc>().add(const ChatToggleAudioPlayback()),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      state.isPlayingAudio ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40.h,
                        child: state.waveformData != null
                            ? StaticWaveform(data: state.waveformData!)
                            : Container(color: Colors.grey.withOpacity(0.2)),
                      ),
                      AppDimens.xs.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(state.recordedAudioDuration ?? Duration.zero),
                            style: AppStyles.bodySmall,
                          ),
                          Text(
                            FileUtils.getFileSize(state.recordedAudioPath!),
                            style: AppStyles.bodySmall.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppDimens.md.width,
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red),
                  onPressed: () => context.read<ChatBloc>().add(const ChatDeleteRecordedAudio()),
                ),
              ],
            ),
            AppDimens.md.height,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: null, // Explicitly null to show I'm replacing this specific block if needed, but actually just adding style
                    onChanged: (text) => context.read<ChatBloc>().add(ChatUpdateCaption(text)),
                    style: AppStyles.bodyRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Izoh qo\'shish...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                  ),
                ),
                AppDimens.sm.width,
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    context.read<ChatBloc>().add(
                          ChatSendMessage(
                            type: ChatMessageType.audio,
                            content: state.recordedAudioPath!,
                            caption: state.caption,
                          ),
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _ChatImageSelectionPreview extends StatelessWidget {
  final ChatState state;

  const _ChatImageSelectionPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatActionPreview(
              replyingMessage: state.replyingMessage,
              editingMessage: state.editingMessage,
              onCancelAction: () {
                if (state.editingMessage != null) {
                  context.read<ChatBloc>().add(const ChatCancelEditing());
                }
                if (state.replyingMessage != null) {
                  context.read<ChatBloc>().add(const ChatCancelReply());
                }
              },
            ),
            SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.selectedImages.length + 1,
                separatorBuilder: (_, __) => AppDimens.sm.width,
                itemBuilder: (context, index) {
                  if (index == state.selectedImages.length) {
                    return InkWell(
                      onTap: () {
                        // We need access to gallery service here, or trigger parent
                        // But ChatInputSection handles _showImagePicker
                        // We can't access parent methods easily.
                        // Best way: Use ChatBloc to get service or use ChatPickImages event if handled (but ChatPickImages event is empty currently)
                        // Or pass callback.
                        
                        // For Quick fix, we can duplicate logic or better:
                        // context.read<ChatBloc>().galleryService...
                        final galleryService = context.read<ChatBloc>().galleryService;
                         showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ChatImagePickerSheet(galleryService: galleryService),
                        );
                      },
                      child: Container(
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Icon(Icons.add, size: 30.r, color: Colors.grey),
                      ),
                    );
                  }

                  final path = state.selectedImages[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(path),
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () => context.read<ChatBloc>().add(ChatRemoveSelectedImage(path)),
                          child: CircleAvatar(
                            radius: 10.r,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 14.r, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            FileUtils.getFileSize(path),
                            style: TextStyle(color: Colors.white, fontSize: 8.sp),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppDimens.md.height,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (text) => context.read<ChatBloc>().add(ChatUpdateCaption(text)),
                    style: AppStyles.bodyRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Izoh qo\'shish...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                  ),
                ),
                AppDimens.sm.width,
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final images = state.selectedImages;
                    final totalImages = images.length;
                    final caption = state.caption;
                    const chunkSize = 9;

                    for (var i = 0; i < totalImages; i += chunkSize) {
                      final end = (i + chunkSize < totalImages) ? i + chunkSize : totalImages;
                      final chunk = images.sublist(i, end);
                      // Send caption only with the first batch
                      // Also send subsequent batches as albums if > 1, or single image if 1
                      final currentCaption = (i == 0) ? caption : null;

                      if (chunk.length == 1) {
                         context.read<ChatBloc>().add(
                              ChatSendMessage(
                                type: ChatMessageType.image,
                                content: chunk.first,
                                caption: currentCaption,
                              ),
                            );
                      } else {
                         context.read<ChatBloc>().add(
                              ChatSendMessage(
                                type: ChatMessageType.album,
                                content: chunk.first, // Fallback preview
                                images: chunk,
                                caption: currentCaption,
                              ),
                            );
                      }
                    }
                    context.read<ChatBloc>().add(const ChatClearSelection());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
