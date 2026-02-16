import '../../domain/entities/comment_entity.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userName;
  final String? userRole;
  final String userAvatarPath;
  final String content;
  final DateTime createdAt;

  final List<CommentModel>? replies;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userName,
    this.userRole,
    required this.userAvatarPath,
    required this.content,
    required this.createdAt,
    this.replies,
  });

  CommentEntity toEntity() => CommentEntity(
    id: id,
    postId: postId,
    userName: userName,
    userRole: userRole,
    userAvatarPath: userAvatarPath,
    content: content,
    createdAt: createdAt,
    replies: replies?.map((e) => e.toEntity()).toList(),
  );

  factory CommentModel.fromEntity(CommentEntity entity) => CommentModel(
    id: entity.id,
    postId: entity.postId,
    userName: entity.userName,
    userRole: entity.userRole,
    userAvatarPath: entity.userAvatarPath,
    content: entity.content,
    createdAt: entity.createdAt,
    replies: entity.replies?.map((e) => CommentModel.fromEntity(e)).toList(),
  );
}
