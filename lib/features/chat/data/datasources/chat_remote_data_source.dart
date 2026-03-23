import 'package:dio/dio.dart';
import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';

abstract class ChatRemoteDataSource {
  Future<Result<Map<String, dynamic>>> openPrivateChat(String receiverId, String receiverRole);
  Future<Result<List<dynamic>>> getMyPrivateChats();
  Future<Result<List<dynamic>>> searchMarkets(String query);
  Future<Result<void>> markMessageSeen(String messageId);
  Future<Result<void>> editMessage(String messageId, String text);
  Future<Result<void>> deleteMessage(String messageId);
  Future<Result<String>> uploadMedia(String type, String filePath);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient client;

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<Result<Map<String, dynamic>>> openPrivateChat(String receiverId, String receiverRole) async {
    final response = await client.post<Map<String, dynamic>>('private-chat', data: {
      'receiverId': receiverId,
      'receiverRole': receiverRole,
    });

    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data']),
    );
  }

  @override
  Future<Result<List<dynamic>>> getMyPrivateChats() async {
    final response = await client.get<Map<String, dynamic>>('private-chat/me');

    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data'] as List),
    );
  }

  @override
  Future<Result<List<dynamic>>> searchMarkets(String query) async {
    final response = await client.get<Map<String, dynamic>>('market', queryParams: {'username': query});

    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data'] as List),
    );
  }

  @override
  Future<Result<void>> markMessageSeen(String messageId) async {
    final response = await client.patch<Map<String, dynamic>>('message/$messageId/seen', data: {});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<void>> editMessage(String messageId, String text) async {
    final response = await client.patch<Map<String, dynamic>>('message/$messageId', data: {'text': text});
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    final response = await client.delete<Map<String, dynamic>>('message/$messageId');
    return response.fold(
      (error) => Result.error(error),
      (_) => Result.ok(null),
    );
  }

  @override
  Future<Result<String>> uploadMedia(String type, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });

    final response = await client.post<Map<String, dynamic>>('message/upload/$type', data: formData);

    return response.fold(
      (error) => Result.error(error),
      (data) => Result.ok(data['data']['path'] as String),
    );
  }
}
