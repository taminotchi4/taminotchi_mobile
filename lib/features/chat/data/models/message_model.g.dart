// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      privateChatId: fields[1] as String?,
      groupId: fields[2] as String?,
      commentId: fields[3] as String?,
      senderId: fields[4] as String,
      senderName: fields[5] as String,
      senderAvatar: fields[6] as String?,
      type: fields[7] as String,
      text: fields[8] as String?,
      mediaPath: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      isRead: fields[11] as bool,
      replyToId: fields[12] as String?,
      status: fields[13] as String?,
      isSending: fields[14] as bool,
      localPath: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.privateChatId)
      ..writeByte(2)
      ..write(obj.groupId)
      ..writeByte(3)
      ..write(obj.commentId)
      ..writeByte(4)
      ..write(obj.senderId)
      ..writeByte(5)
      ..write(obj.senderName)
      ..writeByte(6)
      ..write(obj.senderAvatar)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.text)
      ..writeByte(9)
      ..write(obj.mediaPath)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.isRead)
      ..writeByte(12)
      ..write(obj.replyToId)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.isSending)
      ..writeByte(15)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
