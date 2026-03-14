import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/post_status.dart';
import 'post_category_model.dart';
import 'group_model.dart';

class PostImageModel {
  final String path;
  final bool isLocal;

  const PostImageModel({
    required this.path,
    required this.isLocal,
  });

  PostImageEntity toEntity() => PostImageEntity(path: path, isLocal: isLocal);

  factory PostImageModel.fromEntity(PostImageEntity entity) =>
      PostImageModel(path: entity.path, isLocal: entity.isLocal);
}



class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarPath;
  final String content;
  final List<PostImageModel> images;
  final PostCategoryModel category;
  final DateTime createdAt;
  final int privateReplyCount;
  final PostStatus status;
  final String? price;
  final String? address;
  final String? authorPhone;
  final List<GroupModel> groups;
  final String? commentId;
  final int commentMessageCount;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarPath,
    required this.content,
    required this.images,
    required this.category,
    required this.createdAt,
    required this.privateReplyCount,
    this.status = PostStatus.active,
    this.price,
    this.address,
    this.authorPhone,
    this.groups = const [],
    this.commentId,
    this.commentMessageCount = 0,
  });

  PostEntity toEntity() => PostEntity(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorAvatarPath: authorAvatarPath,
    content: content,
    images: images.map((e) => e.toEntity()).toList(),
    category: category.toEntity(),
    createdAt: createdAt,
    privateReplyCount: privateReplyCount,
    status: status,
    price: price,
    address: address,
    authorPhone: authorPhone,
    groups: groups.map((e) => e.toEntity()).toList(),
    commentId: commentId,
    commentMessageCount: commentMessageCount,
  );

  factory PostModel.fromEntity(PostEntity entity) => PostModel(
        id: entity.id,
        authorId: entity.authorId,
        authorName: entity.authorName,
        authorAvatarPath: entity.authorAvatarPath,
        content: entity.content,
        images: entity.images.map(PostImageModel.fromEntity).toList(),
        category: PostCategoryModel.fromEntity(entity.category),
        createdAt: entity.createdAt,
        privateReplyCount: entity.privateReplyCount,
        status: entity.status,
        price: entity.price,
        address: entity.address,
        authorPhone: entity.authorPhone,
        groups: entity.groups.map(GroupModel.fromEntity).toList(),
        commentId: entity.commentId,
        commentMessageCount: entity.commentMessageCount,
      );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>?;
    final categoryData = json['category'] as Map<String, dynamic>?;
    final photos = json['photos'] as List? ?? [];

    return PostModel(
      id: json['id'] ?? '',
      authorId: json['clientId'] ?? '',
      authorName: client?['fullName'] ?? client?['username'] ?? 'Foydalanuvchi',
      authorAvatarPath: client?['photoPath'] ?? 'assets/icons/ic_user.svg',
      content: json['text'] ?? '',
      images: photos
          .map((p) => PostImageModel(path: p['path'] ?? '', isLocal: false))
          .toList(),
      category: PostCategoryModel(
        id: json['categoryId'] ?? '',
        name: categoryData?['nameUz'] ?? categoryData?['nameRu'] ?? '',
        iconPath: categoryData?['iconUrl'] ?? 'assets/icons/ic_category.svg',
        parentId: json['supCategoryId'],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      privateReplyCount: json['answerCount'] ?? 0,
      status: json['status'] == 'archived' ? PostStatus.archived : PostStatus.active,
      price: json['price']?.toString().split('.').first,
      address: json['adressname'] as String?,
      authorPhone: client?['phoneNumber'] as String?,
      groups: (json['groups'] as List? ?? [])
          .map((g) => GroupModel.fromJson(g))
          .toList(),
      commentId: json['commentId'] as String?,
      commentMessageCount: json['commentMessageCount'] ?? 0,
    );
  }
}
