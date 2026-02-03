class CommentEntity {
  final String id;
  final String postId;
  final String userName;
  final String userAvatarPath;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userName,
    required this.userAvatarPath,
    required this.content,
    required this.createdAt,
  });
}
