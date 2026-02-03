import '../../domain/entities/comment_entity.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userName;
  final String userAvatarPath;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userName,
    required this.userAvatarPath,
    required this.content,
    required this.createdAt,
  });

  CommentEntity toEntity() => CommentEntity(
    id: id,
    postId: postId,
    userName: userName,
    userAvatarPath: userAvatarPath,
    content: content,
    createdAt: createdAt,
  );

  factory CommentModel.fromEntity(CommentEntity entity) => CommentModel(
    id: entity.id,
    postId: entity.postId,
    userName: entity.userName,
    userAvatarPath: entity.userAvatarPath,
    content: entity.content,
    createdAt: entity.createdAt,
  );
}
