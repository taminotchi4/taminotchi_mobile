import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/get_or_create_chat_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../data/services/audio_recorder_service.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/gallery_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetOrCreateChatUseCase getOrCreateChatUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final AudioRecorderService audioRecorder;
  final AudioPlayerService audioPlayer;
  final GalleryService galleryService;
  
  Timer? _waveformTimer;
  StreamSubscription? _audioSubscription;

  ChatBloc({
    required this.getOrCreateChatUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.audioRecorder,
    required this.audioPlayer,
    required this.galleryService,
  }) : super(ChatState.initial()) {
    on<ChatStarted>(_onStarted);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatStartRecordingAudio>(_onStartRecordingAudio);
    on<ChatStopRecordingAudio>(_onStopRecordingAudio);
    on<ChatDeleteRecordedAudio>(_onDeleteRecordedAudio);
    on<ChatToggleAudioPlayback>(_onToggleAudioPlayback);
    on<ChatToggleMessageAudioPlayback>(_onToggleMessageAudioPlayback);
    on<ChatAudioPlaybackStopped>(_onAudioPlaybackStopped);
    on<ChatPickImages>(_onPickImages);
    on<ChatAddSelectedImage>(_onAddSelectedImage);
    on<ChatRemoveSelectedImage>(_onRemoveSelectedImage);
    on<ChatUpdateCaption>(_onUpdateCaption);
    on<ChatClearSelection>(_onClearSelection);
    on<ChatStartEditing>(_onStartEditing);
    on<ChatCancelEditing>(_onCancelEditing);
    on<ChatSubmitEdit>(_onSubmitEdit);
    on<ChatReplyToMessage>(_onReplyToMessage);
    on<ChatCancelReply>(_onCancelReply);
    on<ChatDeleteMessage>(_onDeleteMessage);
    on<ChatEnterSelectionMode>(_onEnterSelectionMode);
    on<ChatExitSelectionMode>(_onExitSelectionMode);
    on<ChatToggleMessageSelection>(_onToggleMessageSelection);

    _initAudioListener();
  }

  void _initAudioListener() {
    _audioSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        add(const ChatAudioPlaybackStopped());
      }
    });
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true));
    final chatResult = await getOrCreateChatUseCase(
      sellerId: event.sellerId,
      userId: event.userId,
    );
    if (emit.isDone) return;
    await chatResult.fold(
      (error) async => emit(state.copyWith(isLoading: false)),
      (chat) async {
        final messagesResult = await getMessagesUseCase(chat.id);
        if (emit.isDone) return;
        messagesResult.fold(
          (_) => emit(state.copyWith(isLoading: false, chat: chat)),
          (messages) => emit(state.copyWith(
            isLoading: false,
            chat: chat,
            messages: messages,
          )),
        );
      },
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.chat;
    if (chat == null) return;
    if (event.content.trim().isEmpty && event.type == ChatMessageType.text) return;
    
    // Create message with 'sending' status
    final message = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chat.id,
      senderId: chat.userId,
      senderName: 'Mening akkauntim',
      isSeller: false,
      type: event.type,
      content: event.content,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      caption: event.caption,
      images: event.images,
      replyToId: state.replyingMessage?.id,
      replyToMessage: state.replyingMessage,
    );
    
    // Add message to list immediately with 'sending' status
    emit(state.copyWith(
      messages: [...state.messages, message],
      clearRecordedAudio: true,
      clearSelectedImages: true,
      clearReplying: true,
    ));
    
    // Try to send
    final result = await sendMessageUseCase(message);
    result.fold(
      (_) {
        // Failed - update status to failed
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == message.id) {
            return msg.copyWith(status: MessageStatus.failed);
          }
          return msg;
        }).toList();
        
        emit(state.copyWith(messages: updatedMessages));
      },
      (sent) {
        // Success - update status to sent
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == message.id) {
            return sent.copyWith(status: MessageStatus.sent);
          }
          return msg;
        }).toList();
        
        emit(state.copyWith(messages: updatedMessages));
      },
    );
  }

  Future<void> _onStartRecordingAudio(
    ChatStartRecordingAudio event,
    Emitter<ChatState> emit,
  ) async {
    final started = await audioRecorder.startRecording();
    if (started) {
      emit(state.copyWith(isRecordingAudio: true));
      
      // Start real-time waveform updates
      _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!state.isRecordingAudio) {
          timer.cancel();
          return;
        }
        
        final waveformData = audioRecorder.amplitudeData;
        emit(state.copyWith(recordingWaveformData: waveformData));
      });
    }
  }

  Future<void> _onStopRecordingAudio(
    ChatStopRecordingAudio event,
    Emitter<ChatState> emit,
  ) async {
    _waveformTimer?.cancel();
    _waveformTimer = null;
    
    final result = await audioRecorder.stopRecording();
    
    if (result.path != null && result.path!.isNotEmpty) {
      emit(state.copyWith(
        isRecordingAudio: false,
        recordedAudioPath: result.path,
        recordedAudioDuration: result.duration,
        waveformData: result.waveform,
      ));
    } else {
      emit(state.copyWith(isRecordingAudio: false));
    }
  }

  void _onDeleteRecordedAudio(
    ChatDeleteRecordedAudio event,
    Emitter<ChatState> emit,
  ) {
    audioPlayer.stop();
    emit(state.copyWith(
      clearRecordedAudio: true,
      isPlayingAudio: false,
    ));
  }

  void _onToggleAudioPlayback(
    ChatToggleAudioPlayback event,
    Emitter<ChatState> emit,
  ) async {
    final path = state.recordedAudioPath;
    if (path == null) return;

    if (state.isPlayingAudio) {
      await audioPlayer.pause();
      emit(state.copyWith(isPlayingAudio: false));
    } else {
      await audioPlayer.play(path);
      emit(state.copyWith(isPlayingAudio: true));
    }
  }

  void _onToggleMessageAudioPlayback(
    ChatToggleMessageAudioPlayback event,
    Emitter<ChatState> emit,
  ) async {
    // If currently playing this message, pause it
    if (state.playingMessageId == event.messageId) {
      await audioPlayer.stop();
      emit(state.copyWith(clearPlayingMessage: true));
    } else {
      // Stop any currently playing audio
      await audioPlayer.stop();
      
      // Play the new audio
      await audioPlayer.play(event.audioPath);
      emit(state.copyWith(playingMessageId: event.messageId));
    }
  }

  void _onAudioPlaybackStopped(
    ChatAudioPlaybackStopped event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isPlayingAudio: false,
      clearPlayingMessage: true,
    ));
  }

  void _onPickImages(
    ChatPickImages event,
    Emitter<ChatState> emit,
  ) {
    // This will be handled by the UI showing the bottom sheet
  }

  void _onAddSelectedImage(
    ChatAddSelectedImage event,
    Emitter<ChatState> emit,
  ) {
    final updatedImages = [...state.selectedImages, event.imagePath];
    emit(state.copyWith(selectedImages: updatedImages));
  }

  void _onRemoveSelectedImage(
    ChatRemoveSelectedImage event,
    Emitter<ChatState> emit,
  ) {
    final updatedImages = state.selectedImages.where((img) => img != event.imagePath).toList();
    emit(state.copyWith(selectedImages: updatedImages));
  }

  void _onUpdateCaption(
    ChatUpdateCaption event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(caption: event.caption));
  }

  void _onClearSelection(
    ChatClearSelection event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(clearSelectedImages: true));
  }

  void _onStartEditing(ChatStartEditing event, Emitter<ChatState> emit) {
    emit(state.copyWith(editingMessage: event.message, clearReplying: true));
  }

  void _onCancelEditing(ChatCancelEditing event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearEditing: true));
  }

  void _onSubmitEdit(ChatSubmitEdit event, Emitter<ChatState> emit) {
    final editedMsg = state.editingMessage;
    if (editedMsg != null) {
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == editedMsg.id) {
          return msg.copyWith(content: event.newContent);
        }
        return msg;
      }).toList();
      emit(state.copyWith(messages: updatedMessages, clearEditing: true));
      // Todo: Call UseCase to sync with backend
    }
  }

  void _onReplyToMessage(ChatReplyToMessage event, Emitter<ChatState> emit) {
    emit(state.copyWith(replyingMessage: event.message, clearEditing: true));
  }

  void _onCancelReply(ChatCancelReply event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearReplying: true));
  }

  void _onDeleteMessage(ChatDeleteMessage event, Emitter<ChatState> emit) {
    final updatedMessages = state.messages.where((msg) => msg.id != event.messageId).toList();
    emit(state.copyWith(messages: updatedMessages));
    // Todo: Call UseCase
  }

  void _onEnterSelectionMode(ChatEnterSelectionMode event, Emitter<ChatState> emit) {
     emit(state.copyWith(clearSelection: true));
  }

  void _onExitSelectionMode(ChatExitSelectionMode event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearSelection: true));
  }

  void _onToggleMessageSelection(ChatToggleMessageSelection event, Emitter<ChatState> emit) {
    final ids = List<String>.from(state.selectedMessageIds);
    if (ids.contains(event.messageId)) {
      ids.remove(event.messageId);
    } else {
      ids.add(event.messageId);
    }
    emit(state.copyWith(selectedMessageIds: ids));
  }

  @override
  Future<void> close() {
    _waveformTimer?.cancel();
    _audioSubscription?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    return super.close();
  }
}
