import '../../domain/entities/chat_message_entity.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class ChatStarted extends ChatEvent {
  final String sellerId;
  final String userId;

  const ChatStarted({required this.sellerId, required this.userId});
}

class ChatSendMessage extends ChatEvent {
  final ChatMessageType type;
  final String content;
  final String? caption;
  final List<String> images;

  const ChatSendMessage({
    required this.type,
    required this.content,
    this.caption,
    this.images = const [],
  });
}

class ChatStartRecordingAudio extends ChatEvent {
  const ChatStartRecordingAudio();
}

class ChatStopRecordingAudio extends ChatEvent {
  const ChatStopRecordingAudio();
}

class ChatDeleteRecordedAudio extends ChatEvent {
  const ChatDeleteRecordedAudio();
}

class ChatToggleAudioPlayback extends ChatEvent {
  const ChatToggleAudioPlayback();
}

class ChatToggleMessageAudioPlayback extends ChatEvent {
  final String messageId;
  final String audioPath;

  const ChatToggleMessageAudioPlayback({
    required this.messageId,
    required this.audioPath,
  });
}

class ChatPickImages extends ChatEvent {
  const ChatPickImages();
}

class ChatAddSelectedImage extends ChatEvent {
  final String imagePath;

  const ChatAddSelectedImage(this.imagePath);
}

class ChatRemoveSelectedImage extends ChatEvent {
  final String imagePath;

  const ChatRemoveSelectedImage(this.imagePath);
}

class ChatUpdateCaption extends ChatEvent {
  final String caption;

  const ChatUpdateCaption(this.caption);
}

class ChatClearSelection extends ChatEvent {
  const ChatClearSelection();
}

class ChatAudioPlaybackStopped extends ChatEvent {
  const ChatAudioPlaybackStopped();
}

class ChatStartEditing extends ChatEvent {
  final ChatMessageEntity message;
  const ChatStartEditing(this.message);
}

class ChatCancelEditing extends ChatEvent {
  const ChatCancelEditing();
}

class ChatSubmitEdit extends ChatEvent {
  final String newContent;
  const ChatSubmitEdit(this.newContent);
}

class ChatReplyToMessage extends ChatEvent {
  final ChatMessageEntity message;
  const ChatReplyToMessage(this.message);
}

class ChatCancelReply extends ChatEvent {
  const ChatCancelReply();
}

class ChatDeleteMessage extends ChatEvent {
  final String messageId;
  const ChatDeleteMessage(this.messageId);
}

class ChatEnterSelectionMode extends ChatEvent {
  const ChatEnterSelectionMode();
}

class ChatExitSelectionMode extends ChatEvent {
  const ChatExitSelectionMode();
}

class ChatToggleMessageSelection extends ChatEvent {
  final String messageId;
  const ChatToggleMessageSelection(this.messageId);
}
