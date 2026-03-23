import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';

abstract class GroupRemoteDataSource {
  Future<Result<List<dynamic>>> getGroups();
  Future<Result<Map<String, dynamic>>> getGroupById(String id);
  Future<Result<List<dynamic>>> getGroupMembers(String id);
  Future<Result<List<dynamic>>> getMyGroups();
  Future<Result<void>> joinGroup(String id);
  Future<Result<void>> leaveGroup(String id);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final ApiClient client;

  GroupRemoteDataSourceImpl({required this.client});

  @override
  Future<Result<List<dynamic>>> getGroups() async {
    final response = await client.get<Map<String, dynamic>>('group');
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data'] as List),
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> getGroupById(String id) async {
    final response = await client.get<Map<String, dynamic>>('group/$id');
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data']),
    );
  }

  @override
  Future<Result<List<dynamic>>> getGroupMembers(String id) async {
    final response = await client.get<Map<String, dynamic>>('group/$id/members');
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data'] as List),
    );
  }

  @override
  Future<Result<List<dynamic>>> getMyGroups() async {
    final response = await client.get<Map<String, dynamic>>('group/me/groups');
    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data'] as List),
    );
  }

  @override
  Future<Result<void>> joinGroup(String id) async {
    final response = await client.post<Map<String, dynamic>>('group/$id/join', data: {});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<void>> leaveGroup(String id) async {
    final response = await client.post<Map<String, dynamic>>('group/$id/leave', data: {});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }
}
