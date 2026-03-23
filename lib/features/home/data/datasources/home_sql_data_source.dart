import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/post_status.dart';
import '../models/group_model.dart';
import '../models/post_category_model.dart';
import '../models/post_model.dart';

class HomeSqlDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- Categories ---

  Future<void> saveCategories(List<PostCategoryModel> categories) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('categories');
      
      for (var cat in categories) {
        await txn.insert('categories', {
          'id': cat.id,
          'parentId': null,
          'data': jsonEncode(cat.toJson()),
        });

        if (cat.subcategories != null) {
          for (var sub in cat.subcategories!) {
            await txn.insert('categories', {
              'id': sub.id,
              'parentId': cat.id,
              'data': jsonEncode(sub.toString()),
            });
          }
        }
      }
    });
  }

  Future<List<PostCategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    
    if (maps.isEmpty) return [];

    final List<PostCategoryModel> all = maps.map((m) {
      final data = jsonDecode(m['data']) as Map<String, dynamic>;
      // Ensure parentId is consistent if it changed in data but not in col
      return PostCategoryModel.fromJson(data);
    }).toList();

    final List<PostCategoryModel> main = all.where((c) => c.parentId == null).toList();
    
    return main.map((m) {
      final subs = all.where((c) => c.parentId == m.id).toList();
      return PostCategoryModel(
        id: m.id,
        name: m.name,
        iconPath: m.iconPath,
        subcategories: subs.isEmpty ? null : subs,
      );
    }).toList();
  }

  // --- Groups ---

  Future<void> saveGroups(List<GroupModel> groups) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    
    for (var g in groups) {
      batch.insert(
        'chat_groups',
        {
          'id': g.id,
          'categoryId': g.categoryId,
          'data': jsonEncode(g.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<GroupModel>> getGroupsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_groups',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return maps.map((m) => GroupModel.fromJson(jsonDecode(m['data']))).toList();
  }

  // --- Posts ---

  Future<void> savePosts(List<PostModel> posts) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    
    for (var p in posts) {
      batch.insert(
        'posts',
        {
          'id': p.id,
          'categoryId': p.category.id,
          'data': jsonEncode(_postToJson(p)),
          'createdAt': p.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PostModel>> getPosts({String? categoryId}) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: categoryId != null ? 'categoryId = ?' : null,
      whereArgs: categoryId != null ? [categoryId] : null,
      orderBy: 'createdAt DESC',
    );

    return maps.map((m) => _postFromJson(jsonDecode(m['data']))).toList();
  }

  // Helper because PostModel might not have a full toJson yet
  Map<String, dynamic> _postToJson(PostModel p) {
    return {
      'id': p.id,
      'clientId': p.authorId,
      'client': {
        'fullName': p.authorName,
        'photoPath': p.authorAvatarPath,
        'phoneNumber': p.authorPhone,
      },
      'text': p.content,
      'photos': p.images.map((img) => {'path': img.path}).toList(),
      'categoryId': p.category.id,
      'category': {
        'nameUz': p.category.name,
        'iconUrl': p.category.iconPath,
      },
      'supCategoryId': p.category.parentId,
      'createdAt': p.createdAt.toIso8601String(),
      'answerCount': p.privateReplyCount,
      'status': p.status == PostStatus.archived ? 'archived' : 'active',
      'price': p.price,
      'adressname': p.address,
      'commentId': p.commentId,
      'commentMessageCount': p.commentMessageCount,
      'groups': p.groups.map((g) => g.toJson()).toList(),
    };
  }

  PostModel _postFromJson(Map<String, dynamic> json) => PostModel.fromJson(json);
}
