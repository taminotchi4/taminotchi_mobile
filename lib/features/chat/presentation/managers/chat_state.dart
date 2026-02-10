import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatState {
  final ChatEntity? chat;
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final bool isRecordingAudio;
  final String? recordedAudioPath;
  final bool isPlayingAudio;
  final Duration? recordedAudioDuration;
  final List<double>? waveformData;
  final List<double>? recordingWaveformData;
  final String? playingMessageId;
  final List<String> selectedImages;
  final String caption;

  const ChatState({
    required this.chat,
    required this.messages,
    required this.isLoading,
    this.isRecordingAudio = false,
    this.recordedAudioPath,
    this.isPlayingAudio = false,
    this.recordedAudioDuration,
    this.waveformData,
    this.recordingWaveformData,
    this.playingMessageId,
    this.selectedImages = const [],
    this.caption = '',
    this.editingMessage,
    this.replyingMessage,
    this.selectedMessageIds = const [],
  });

  final ChatMessageEntity? editingMessage;
  final ChatMessageEntity? replyingMessage;
  final List<String> selectedMessageIds;

  factory ChatState.initial() => const ChatState(
    chat: null,
    messages: [],
    isLoading: false,
    isRecordingAudio: false,
    recordedAudioPath: null,
    isPlayingAudio: false,
    recordedAudioDuration: null,
    waveformData: null,
    recordingWaveformData: null,
    playingMessageId: null,
    selectedImages: [],
    caption: '',
    editingMessage: null,
    replyingMessage: null,
    selectedMessageIds: [],
  );

  ChatState copyWith({
    ChatEntity? chat,
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    bool? isRecordingAudio,
    String? recordedAudioPath,
    bool? isPlayingAudio,
    Duration? recordedAudioDuration,
    List<double>? waveformData,
    List<double>? recordingWaveformData,
    String? playingMessageId,
    List<String>? selectedImages,
    String? caption,
    ChatMessageEntity? editingMessage,
    ChatMessageEntity? replyingMessage,
    List<String>? selectedMessageIds,
    bool clearRecordedAudio = false,
    bool clearPlayingMessage = false,
    bool clearSelectedImages = false,
    bool clearEditing = false,
    bool clearReplying = false,
    bool clearSelection = false,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      recordedAudioPath: clearRecordedAudio ? null : (recordedAudioPath ?? this.recordedAudioPath),
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      recordedAudioDuration: clearRecordedAudio ? null : (recordedAudioDuration ?? this.recordedAudioDuration),
      waveformData: clearRecordedAudio ? null : (waveformData ?? this.waveformData),
      recordingWaveformData: isRecordingAudio == false ? null : (recordingWaveformData ?? this.recordingWaveformData),
      playingMessageId: clearPlayingMessage ? null : (playingMessageId ?? this.playingMessageId),
      selectedImages: clearSelectedImages ? [] : (selectedImages ?? this.selectedImages),
      caption: clearSelectedImages || clearRecordedAudio ? '' : (caption ?? this.caption),
      editingMessage: clearEditing ? null : (editingMessage ?? this.editingMessage),
      replyingMessage: clearReplying ? null : (replyingMessage ?? this.replyingMessage),
      selectedMessageIds: clearSelection ? [] : (selectedMessageIds ?? this.selectedMessageIds),
    );
  }
}
