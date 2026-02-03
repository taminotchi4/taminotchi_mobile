import 'dart:math';

import '../../../../core/utils/icons.dart';
import '../../domain/entities/user_role.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class HomeLocalDataSource {
  static final List<PostModel> _posts = [];
  static final Map<String, List<CommentModel>> _comments = {};
  static bool _initialized = false;

  final Random _random = Random();
  final String _currentUserId = 'user_1';
  final UserRole _currentUserRole = UserRole.user;
  static const int _maxPrivateReplies = 26;
  late final List<PostCategoryModel> _categories = [
    const PostCategoryModel(
      id: 'tech',
      name: 'Texnologiya',
      iconPath: AppIcons.categoryTech,
    ),
    const PostCategoryModel(
      id: 'food',
      name: 'Oshxona',
      iconPath: AppIcons.categoryFood,
    ),
    const PostCategoryModel(
      id: 'service',
      name: 'Xizmat',
      iconPath: AppIcons.categoryService,
    ),
    const PostCategoryModel(
      id: 'event',
      name: 'Tadbir',
      iconPath: AppIcons.categoryEvent,
    ),
    const PostCategoryModel(
      id: 'other',
      name: 'Boshqa',
      iconPath: AppIcons.categoryOther,
    ),
  ];

  void ensureSeeded() {
    if (_initialized) return;
    _initialized = true;

    final now = DateTime.now();
    const seedMinutes = 15;
    const seedHourOne = 1;
    final seedPosts = [
      PostModel(
        id: 'post_1',
        authorId: 'user_2',
        authorName: 'Akmal',
        authorAvatarPath: AppIcons.user,
        content:
            'Bugun yangi loyiha ustida ishlayapman. Fikrlar va maslahatlar bolsa, yozib qoldiring.',
        images: const [],
        category: _categories[0],
        createdAt: now.subtract(const Duration(minutes: seedMinutes)),
        privateReplyCount: _random.nextInt(_maxPrivateReplies),
      ),
      PostModel(
        id: 'post_2',
        authorId: 'user_3',
        authorName: 'Dilnoza',
        authorAvatarPath: AppIcons.user,
        content:
            'Bugun ertalabki mashgulotdan keyin ajoyib kayfiyat. Hamma qanday?',
        images: const [],
        category: _categories[1],
        createdAt: now.subtract(const Duration(hours: seedHourOne)),
        privateReplyCount: _random.nextInt(_maxPrivateReplies),
      ),
    ];

    _posts.addAll(seedPosts);
    for (final post in seedPosts) {
      _comments[post.id] = _generateComments(post.id);
    }
  }

  List<PostModel> getAllPosts() {
    ensureSeeded();
    return List.unmodifiable(_posts);
  }

  List<PostModel> getMyPosts(String userId) {
    ensureSeeded();
    return List.unmodifiable(
      _posts.where((post) => post.authorId == userId).toList(),
    );
  }

  PostModel addPost({
    required String content,
    required List<PostImageModel> images,
    required PostCategoryModel category,
  }) {
    ensureSeeded();
    final post = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: _currentUserId,
      authorName: 'Mening akkauntim',
      authorAvatarPath: AppIcons.user,
      content: content,
      images: images,
      category: category,
      createdAt: DateTime.now(),
      privateReplyCount: _random.nextInt(_maxPrivateReplies),
    );
    _posts.insert(0, post);
    _comments[post.id] = _generateComments(post.id);
    return post;
  }

  PostModel? getPostById(String id) {
    ensureSeeded();
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CommentModel> getComments(String postId) {
    ensureSeeded();
    return List.unmodifiable(_comments[postId] ?? []);
  }

  List<PostCategoryModel> getCategories() {
    ensureSeeded();
    return List.unmodifiable(_categories);
  }

  String getCurrentUserId() => _currentUserId;

  UserRole getCurrentUserRole() => _currentUserRole;

  Map<String, int> getCommentCounts() {
    ensureSeeded();
    return Map.unmodifiable(
      _comments.map((key, value) => MapEntry(key, value.length)),
    );
  }

  List<CommentModel> _generateComments(String postId) {
    const minComments = 1;
    const extraComments = 7;
    const minMinutes = 5;
    const maxMinutes = 120;
    final count = minComments + _random.nextInt(extraComments);
    return List.generate(count, (index) {
      return CommentModel(
        id: '${postId}_comment_$index',
        postId: postId,
        userName: _randomUserName(),
        userAvatarPath: AppIcons.user,
        content: _randomComment(),
        createdAt: DateTime.now()
            .subtract(Duration(minutes: minMinutes + _random.nextInt(maxMinutes))),
      );
    });
  }

  String _randomUserName() {
    const names = ['Sarvar', 'Madina', 'Aziza', 'Kamron', 'Malika', 'Ulugbek'];
    return names[_random.nextInt(names.length)];
  }

  String _randomComment() {
    const comments = [
      'Zor! Fikringiz yoqdi.',
      'Qiziqarli. Davom ettiring.',
      'Men ham shunga oxshashni korganman.',
      'Hozircha yaxshi korinadi.',
      'Ajoyib kayfiyat uchun rahmat!',
      'Buni sinab koramiz.',
    ];
    return comments[_random.nextInt(comments.length)];
  }
}
