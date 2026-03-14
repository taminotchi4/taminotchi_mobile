import '../models/post_category_model.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/client.dart';

abstract class CategoryRemoteDataSource {
  Future<List<PostCategoryModel>> getCategories();
  Future<List<PostCategoryModel>> getSubCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient client;

  CategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostCategoryModel>> getCategories() async {
    final result = await client.get<Map<String, dynamic>>('category');
    
    return result.fold(
      (error) {
        debugPrint('Error fetching categories: $error');
        throw Exception('Failed to load categories: $error');
      },
      (data) {
        if (data['data'] != null) {
          final list = data['data'] as List;
          return list.map((e) => PostCategoryModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<List<PostCategoryModel>> getSubCategories() async {
    final result = await client.get<Map<String, dynamic>>('sup-category');

    return result.fold(
      (error) {
        debugPrint('Error fetching subcategories: $error');
        throw Exception('Failed to load subcategories: $error');
      },
      (data) {
        if (data['data'] != null) {
          final list = data['data'] as List;
          return list.map((e) => PostCategoryModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}
