import 'package:dio/dio.dart';
import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/post_model.dart';

abstract class ElonRemoteDataSource {
  Future<Result<PostModel>> createElon({
    required String text,
    required String categoryId,
    String? supCategoryId,
    String? price,
    String? adressname,
    List<String>? photosPaths,
  });

  Future<Result<List<PostModel>>> getElons({int page = 1, int limit = 100});

  Future<Result<List<PostModel>>> getElonsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 100,
  });

  Future<Result<PostModel>> getElonById(String postId);
  Future<Result<List<PostModel>>> getElonsByGroup({
    required String groupId,
    int page = 1,
    int limit = 100,
  });
  Future<Result<List<PostModel>>> getMyElons();
}

class ElonRemoteDataSourceImpl implements ElonRemoteDataSource {
  final ApiClient client;

  ElonRemoteDataSourceImpl({required this.client});

  @override
  Future<Result<PostModel>> createElon({
    required String text,
    required String categoryId,
    String? supCategoryId,
    String? price,
    String? adressname,
    List<String>? photosPaths,
  }) async {
    final Map<String, dynamic> body = {
      'text': text,
      'categoryId': categoryId,
    };

    if (supCategoryId != null) body['supCategoryId'] = supCategoryId;
    if (price != null) body['price'] = price;
    if (adressname != null) body['adressname'] = adressname;

    final formData = FormData.fromMap(body);

    if (photosPaths != null && photosPaths.isNotEmpty) {
      for (final path in photosPaths) {
        formData.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(path),
        ));
      }
    }

    final response = await client.post<Map<String, dynamic>>('elon', data: formData);

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(PostModel.fromJson(data['data']));
        } catch (e) {
          return Result.error(Exception('Failed to parse created elon: $e'));
        }
      },
    );
  }

  @override
  Future<Result<List<PostModel>>> getElons({int page = 1, int limit = 100}) async {
    final response = await client.get<Map<String, dynamic>>('elon?page=$page&limit=$limit');

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List? ?? [];
          final elons = list.map((json) => PostModel.fromJson(json)).toList();
          return Result.ok(elons);
        } catch (e) {
          return Result.error(Exception('Failed to parse elons: $e'));
        }
      },
    );
  }

  @override
  Future<Result<List<PostModel>>> getElonsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 100,
  }) async {
    // Backend seems to use groupId for category filtering according to seller app
    final response = await client.get<Map<String, dynamic>>(
      'elon?page=$page&limit=$limit&groupId=$categoryId',
    );

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List? ?? [];
          final elons = list.map((json) => PostModel.fromJson(json)).toList();
          return Result.ok(elons);
        } catch (e) {
          return Result.error(Exception('Failed to parse elons: $e'));
        }
      },
    );
  }

  @override
  Future<Result<PostModel>> getElonById(String postId) async {
    final response = await client.get<Map<String, dynamic>>('elon/$postId');

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(PostModel.fromJson(data['data']));
        } catch (e) {
          return Result.error(Exception('Failed to parse elon: $e'));
        }
      },
    );
  }

  @override
  Future<Result<List<PostModel>>> getElonsByGroup({
    required String groupId,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      'elon?page=$page&limit=$limit&groupId=$groupId',
    );

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List? ?? [];
          final elons = list.map((json) => PostModel.fromJson(json)).toList();
          return Result.ok(elons);
        } catch (e) {
          return Result.error(Exception('Failed to parse elons: $e'));
        }
      },
    );
  }

  @override
  Future<Result<List<PostModel>>> getMyElons() async {
    final response = await client.get<Map<String, dynamic>>('client/me/elons');

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List? ?? [];
          final elons = list.map((json) => PostModel.fromJson(json)).toList();
          return Result.ok(elons);
        } catch (e) {
          return Result.error(Exception('Failed to parse my elons: $e'));
        }
      },
    );
  }
}
